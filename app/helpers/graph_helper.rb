module GraphHelper
  def strip_versions(name)
    if name.match(/(.*) \(.*\)/) then
      return $1.to_s
    else
      return name
    end
  end
  
  def get_dep_arr(package, depth)
    nodes = []
    links = []
    pack = Package.find_by_name(package)
    if ((!pack.nil?)&&(depth>0)&&(!pack.depends.nil?)) then
      next_level = pack.depends.split(", ")
      nodes << pack.name
      next_level.each do |i|
        i = strip_versions(i)
        deps = get_dep_arr(i, (depth - 1))
        nodes << deps[0]
        if deps[1] == [] then
          links << [pack.name,i]
        else
          links << deps[1] << [pack.name,i]  
        end
      end
    elsif (depth==0)||(pack.depends.nil?) then
      nodes << package
    else
      nodes << " Ups!"
    end
    
    linksfin = []
    links.flatten!(10)
    cis = (links.length-1)/2
    for i in 0..cis
      linksfin << [links[2*i],links[2*i+1]]
    end
    
    return [nodes.flatten(2).uniq, linksfin.uniq]
  end

  def get_json(package, depth)
    array = get_dep_arr(package, depth)
    json = '{"nodes":['
    nodes = []
    array[0].each do |i|
      nodes << '{"name":"' + i + '","group":1}'
    end
    json << nodes.join(', ')
    json << '],"links":['
    link = []
    hash = Hash[array[0].map.with_index{|*ki| ki}]
    array[1].each do |i|
      link << '{"source":' + hash[i[0]].to_s + ',"target":' + hash[i[1]].to_s + ',"value":1}'
    end
    json << link.join(', ')
    json << ']}'
    json.gsub!(/{"name":"#{package}","group":1}/, "{\"name\":\"#{package}\",\"group\":4}")
    return json
  end
end
