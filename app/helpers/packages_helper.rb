module PackagesHelper
  
  # Method that gets current packages list from Cran
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
  
  def init()
      baliky = getPackages()
      
      baliky.each do |i|
        i.match(/(.*)_(.*).tar.gz/i)
        new = Package.new(name: $1.to_s, version: $2.to_s, archive_name: i.to_s)
        new.save
      end
      UPDATE_PACKAGE_LOG.info("Database was initialized by downloading list of packages from CRAN.")   
  end
  
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
  
  def encoding(file_contents)
    require 'iconv' unless String.method_defined?(:encode)
    if String.method_defined?(:encode)
        file_contents.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
        file_contents.encode!('UTF-8', 'UTF-16')
    else
        ic = Iconv.new('UTF-8', 'UTF-8//IGNORE')
        file_contents = ic.iconv(file_contents)
    end
  end
  
  def downloadPackage(package)
    require 'zlib' 
    require 'open-uri'

    uri = "http://cran.at.r-project.org/src/contrib/" + package.archive_name
    source = open(uri)
    gz = Zlib::GzipReader.new(source) 
    result = encoding(gz.read)
  end
  
  def getDescription(package)
    output = []
    keywords = ["Package", "Title", "Type", "Version", "Author", "Description", "Suggests", "Imports", "Depends",
       "Maintainer", "Extends", "Packaged", "Repository", "URL", "Date/Publication", "License", "LazyData", "Collate"].join("|")
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
  
  def updatePackageInfo(package)
    description = getDescription(package)
    description.each do |desc|
      if desc.match(/Depends: (.*)\z/) then package.update_attributes(depends: $1.to_s) end
      if desc.match(/Imports: (.*)\z/) then package.update_attributes(imports: $1.to_s) end
      if desc.match(/Suggests: (.*)\z/) then package.update_attributes(suggests: $1.to_s) end
      if desc.match(/Description: (.*)\z/) then package.update_attributes(description: $1.to_s) end
      if desc.match(/Author: (.*)\z/) then package.update_attributes(authors: $1.to_s) end
      if desc.match(/Maintainer: (.*)\z/) then package.update_attributes(maintainers: $1.to_s) end
    end
  end
  
  def updatePackages(no)
    current_info = getPackages()
    names = []
    versions = []
    current_info.each do |line|
      line.match(/(.*)_(.*).tar.gz/)
      names << $1
      versions << $2
    end
    hash_current = Hash[names.map.with_index{|*ki| ki}] 
    i = 1
    
    while i<no
      pack = Package.find_by_id(i)
      if pack.depends.nil? then
        updatePackageInfo(pack)
        UPDATE_PACKAGE_LOG.info("Initial info-gathering for package " + pack.name)
      elsif pack.version != versions[hash_current[pack.name]] 
        updatePackageInfo(pack)
        UPDATE_PACKAGE_LOG.info("Update of " + pack.name + " due to newer version on CRAN.")
      end
      i += 1 
    end
  end
end
