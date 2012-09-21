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
    Package.new(name: "R", version: "1", depends: "").save
    Package.new(name: "stats", version: "1", depends: "").save
    Package.new(name: "utils", version: "1", depends: "").save
    Package.new(name: "methods", version: "1", depends: "").save
    Package.new(name: "grid", version: "1", depends: "").save
    Package.new(name: "graphics", version: "1", depends: "").save
    Package.new(name: "grDevices", version: "1", depends: "").save
    Package.new(name: "splines", version: "1", depends: "").save
  end
  # Printing method to html.
  def show()
      output = "<table><tr><th>ID</th><th>Package name</th><th>Version</th><th>Depends on</th></tr>"
      odd = TRUE
      Package.all.each do |i|
        if odd then
          background = "odd" else
          background = "even"
        end
        output << "<tr class = " + background + " center><td>" + i.id.to_s + "</td><td>" + i.name + "</td><td>" + i.version + "</td><td>" + i.depends.to_s + "</td></tr>"
        odd = !odd
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
    source.match(/summary\">(.*?)<\/table>/x)
    source = $1
    source.gsub!(/<\W?a.*?>/,"")
    source.gsub!(/<\/tr>/, " | ")
    source.gsub!(/<\W?t(r|d).*?>/, "")
    source = source.split(" | ")
    source.each do |l|
      l.strip!
    end
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
    
    # Look if there is some new package in the central depository
    if Package.all.length != current_info.length then
      names.each do |i|
        if !(Package.find_by_name(i)) then
          Package.new(name: names[hash_current[i]], version: version[hash_current[i]], archive_name: current_info[hash_current[i]].to_s)
        end
      end
    end
    
    # Update the given number of packages
    names.each do |i|
      pack = Package.find_by_name(i)
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
    end
  end

  # Dependencies are in form of field separated by commas, this parses it
  def parseRawDepends(depends)
    array = depends.split(", ")
    array.each do |l|
      l = l.split(" ")
    end
    return array.to_s
  end
end
