module GeneralHelper
  def vizualizeFoundPackages(array)
    output = ""
    output << '<table class="table table-condensed table-hoover">'
    output << '<tr>'
    output << '<th>Name</th>'
    output << '<th>Version</th>'
    output << '<th>Author</th>'
    output << '</tr>'
    array.each do |i|
      @pack = Package.find_by_name(i)
      output << '<tr>'
      output << '<td>'
      output << link_to("#{@pack.name}", "/packages/#{@pack.name}/")
      output << '</td>'
      output << '<td>'
      output << "#{@pack.version}"
      output << '</td>'
      output << '<td>'
      output << "#{@pack.authors}"
      output << '</td>'
      output << '</tr>'
    end
    output << '</table>'
    return output.html_safe
  end
end
