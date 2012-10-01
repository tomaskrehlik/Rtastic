module PackagesHelper
  
  # Method that gets current packages list from Cran and output is a list of package names
  # in form name_version.tar.gz
  def getPackages()
    require 'net/http'
    uri = URI('http://cran.at.r-project.org/src/contrib/')
    source = Net::HTTP.get(uri)
    table = source.split('<td>')
    packages = []
    table.each do |t| 
      t.match(/">(.*\.tar.gz)<\/a>/i)
      if (!$1.to_s.empty?) 
        packages << $1
      end
    end
    return packages
  end
  
  # Method that takes the unprocessed names in form name_version.tar.gz and creates an entry
  # in the database for all the packages. It only creates basic structure and the info updates will
  # be added by other methods.
  def init()
      baliky = getPackages()
      
      baliky.each do |i|
        i.match(/(.*)_(.*).tar.gz/i)
        new = Package.new(name: $1.to_s, version: $2.to_s, archive_name: i.to_s)
        new.save
      end
      UPDATE_PACKAGE_LOG.info("Database was initialized by downloading list of packages from CRAN.")   
  end
  
  def add_base_packages()
    Package.new(name: "R", version: "1", depends: "", info_harvested: TRUE).save
    Package.new(name: "stats", version: "1", depends: "", info_harvested: TRUE).save
    Package.new(name: "utils", version: "1", depends: "", info_harvested: TRUE).save
    Package.new(name: "methods", version: "1", depends: "", info_harvested: TRUE).save
    Package.new(name: "grid", version: "1", depends: "", info_harvested: TRUE).save
    Package.new(name: "graphics", version: "1", depends: "", info_harvested: TRUE).save
    Package.new(name: "grDevices", version: "1", depends: "", info_harvested: TRUE).save
    Package.new(name: "splines", version: "1", depends: "", info_harvested: TRUE).save
  end
  # Printing method to html.
  def show(start, fin)
      output = "<table class=\"table table-hover table-condensed\"><tr><th>ID</th><th>Package name</th><th>Version</th><th>Depends on</th><th>Generate documentation</th></tr>"
      Package.find((start..fin).to_a).each do |i|
        output << "<tr class = center><td>" + i.id.to_s + "</td><td>" + i.name + "</td><td>" + i.version + "</td><td>" + i.depends.to_s + "</td><td>" + button_to("Generate docs", "/docsbuild/#{i.name}", method: "get", class: "btn btn-mini " + get_documentation_state(i.name) ) + "</td></tr>"
      end
      output << "</table>"
      return output
  end

  # Method that downloads package from central depository and outputs unpackaged version.
  def downloadPackage(package)
    require 'zlib' 
    require 'open-uri'

    uri = "http://cran.at.r-project.org/src/contrib/" + package.archive_name
    source = open(uri)
    gz = Zlib::GzipReader.new(source)
    result = encoding(gz.read)
    return result
  end
  
  # Slow method for getting descriptions. Probably wont have to ever be used. Parses the output
  # of downloadPackage method.
  def getDescription(package)
    output = []
    keywords = ["Package", "Title", "Type", "Version", "Author", "Description", "Suggests", "Imports", "Depends",
       "Maintainer", "Extends", "Packaged", "Repository", "URL", "Date/Publication", "License", "LazyData", "LazyLoad", "Collate"].join("|")
    text = downloadPackage(package).split.join(" ")
    
    text.match(/(Package:\s#{package.name}.*Date\/Publication:\s\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})/)
    description = $1  
    ar = description.to_s.split(" ")
    prev = 0
    for i in 1..ar.length
      if ar[i] =~ /\A(#{keywords}):\z/ then
        output << ar[prev..(i-1)].join(" ")
        prev = i
      end
    end
    output << ar[prev..ar.length].join(" ")
    output
  end
  
  # Fast method for getting descriptions. Parses already parsed sources from www pages of the
  # depositories.
  def getDescriptionHtml(package)
    require 'open-uri'

    uri = "http://cran.at.r-project.org/web/packages/" + package.name + "/index.html"
    source = open(uri).read.split.join(" ")
    source.match(/<p>(.*?)<\/p>/x)
    desc = $1
    source.match(/summary\">(.*?)<\/table>/x)
    source = $1
    source.gsub!(/<\W?a.*?>/,"")
    source.gsub!(/<\/tr>/, " | ")
    source.gsub!(/<\W?t(r|d).*?>/, "")
    source = source.split(" | ")
    source.each do |l|
      l.strip!
    end
    source << "Description: #{desc}"
    return source
  end  
  
  # Parses output of getDescription(Html) and updates info to the database.
  def updatePackageInfo(package, html)
    if html then description = getDescriptionHtml(package) else description = getDescription(package) end
    description.each do |desc|
      if desc.match(/Depends: (.*)\z/) then package.update_attributes(depends: $1.to_s) end
      if desc.match(/Imports: (.*)\z/) then package.update_attributes(imports: $1.to_s) end
      if desc.match(/Suggests: (.*)\z/) then package.update_attributes(suggests: $1.to_s) end
      if desc.match(/Description: (.*)\z/) then package.update_attributes(description: $1.to_s) end
      if desc.match(/Author: (.*)\z/) then package.update_attributes(authors: $1.to_s) end
      if desc.match(/Maintainer: (.*)\z/) then package.update_attributes(maintainers: $1.to_s) end
    end
  end
  
  # Updating routine for packages set for updating the whole database
  def updatePackages(html_way)
    #Get current packages on the repository
    current_info = getPackages()
  
    names = []
    versions = []
    current_info.each do |line|
      line.match(/(.*)_(.*).tar.gz/)
      names << $1
      versions << $2
    end
    hash_current = Hash[names.map.with_index{|*ki| ki}]
    
    # Update the given number of packages
    names.each do |i|
      if pack = Package.find_by_name(i) then
        if !pack.info_harvested then
          updatePackageInfo(pack, html_way)
          pack.update_attributes(info_harvested: TRUE)
          UPDATE_PACKAGE_LOG.info("Initial info-gathering for package " + pack.name + ". Html way: " + html_way.to_s)
        elsif pack.version != versions[hash_current[pack.name]]
          updatePackageInfo(pack, html_way)
          UPDATE_PACKAGE_LOG.info("Update of " + pack.name + " due to newer version on CRAN. Html way: " + html_way.to_s)
        else
          UPDATE_PACKAGE_LOG.info("No reason to update " + pack.name)
        end
      else
        Package.new(name: names[hash_current[i]], version: versions[hash_current[i]], archive_name: current_info[hash_current[i]].to_s).save
      end
    end
  end

  # Dependencies are in form of field separated by commas, this parses it
  def parseRawDepends(depends)
    return "" if depends === nil
    array = depends.split(", ")
    array.each do |l|
      l = l.split(" ")
    end
    return array.to_s
  end

  # Searches the packages database for matching occurances and return array of names of packages that match
  def self.search(q)
    names = []
    Package.select("name").each do |i|
      names << i.name
    end
    match = []
    names.each do |i|
      if i.match(/(#{q})/) then
        match << i
      end
    end
    return match
  end
end







# Parser for documentation

def paranthesis(text_par,tag)
  opening = 1
  nested = 0
  my = text_par.split("\n").join(" ")
  my = my.gsub(/.*#{tag}{/x,"")

  return "" if (my === text_par)
  regexp = ".*?"
    
  my.split("").each do |c|
    if c.eql? "{" then
      opening = opening + 1
      nested = nested + 1
      regexp << "\{.*?"
    elsif c.eql? "}"
      opening = opening - 1
      regexp << "\}.*?" if !(opening===0)
    end
    if opening == 0 then break end
  end
  return regexp
end

def get_content(text, tag)
  regexp = paranthesis(text, tag)
  regexp = "#{tag}{(#{regexp})}"
  text.match(/\\#{regexp}/)
  return $1
end

def parse_Rd_files(package)
  download_source(package)

  Dir["tmp/packdoc/#{package}/man/*.Rd"].each do |function|
    function.match(/\/((\w|\.|\-)+?).Rd/)
    func = $1.to_s
    path = "#{package}\/man\/#{func}.Rd"

    file = File.open("#{Rails.root}/tmp/packdoc/#{path}", "rb")
    source = file.read.split.join(" ")
  
    parts = ["arguments","author","concept","description","details","docType","encoding", "format" ,"keyword",
             "name","note","references","section","seealso","source","title","value","examples","alias",
             "Rdversion", "usage","synopsis"]

    documentation = Hash.new
    documentation.default = ""
    parts.each do |p|
      documentation[p] = get_content(source, p).to_s
    end
    documentation["package"] = package
    Documentation.new(documentation).save
  end

  system("rm -r #{Rails.root}/tmp/packdoc/#{package}")
end

def download_source(package)
  require 'open-uri'
  pack = Package.find_by_name(package)
  package = pack.archive_name
  uri = "http://cran.at.r-project.org/src/contrib/" + package
  open("#{Rails.root}/tmp/packdoc/#{package}", 'wb') do |file|
    file << open(uri).read
  end
  system("tar -xf #{Rails.root}/tmp/packdoc/#{package} -C #{Rails.root}/tmp/packdoc")
  system("rm #{Rails.root}/tmp/packdoc/#{package}")
end

def get_documentation_state(package)
  if Documentation.find_by_package(package).nil? then
    return "btn-danger"
  else 
    return "btn-success"
  end
end

def pagination(where_am_i, how_big_view)
  output = ""
  number = Package.count()
  # There is 5 of the pagination links, now I determine, which should be disabled

  my_page = (where_am_i/how_big_view).floor
  max_page = (number/how_big_view).floor + 1
  distance = [(my_page - 0).abs, (my_page - max_page).abs].min
  disabled = distance
  if disabled>3 then disabled = 3 end
  
  min_show = my_page - 2
  max_show = my_page + 2
  while ((min_show<1)||(max_show>max_page)) do
    if (2*my_page>max_page) then
      min_show -= 1
      max_show -= 1
    else
      min_show += 1
      max_show += 1
    end
  end
  for i in (min_show..max_show) do
    if ((i-min_show + 1)===disabled) then
      dis = "active"
    else
      dis = "disabled"
    end
    output << "<li class=\"#{dis}\"><a href=\"?start=#{i*how_big_view}\">#{i}<\/a><\/li>"
  end
  return output
end
