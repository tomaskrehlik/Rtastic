f = 'pFtest.Rd'
text = []
file = File.open(f, 'r') do |p|
  while line = p.gets
    text << line
  end
end
a = text.join.split.join(" ")

def paranthesis(text_par,tag)
  opening = 1
  nested = 0
  my = text_par.split("\n").join(" ")
  my = my.gsub(/.*#{tag}{/x,"")
    
  my.split("").each do |c|
    if c.eql? "{" then
      opening = opening + 1
      nested = nested + 1
    elsif c.eql? "}"
      opening = opening - 1
    end
    if opening == 0 then break end
  end
  return nested
end

def get_content(text, tag)
  nested_inside = paranthesis(text, tag)
  puts nested_inside
  regexp = ".*?\{.*?\}" * nested_inside
  puts regexp
  text.match(/\\#{tag}{(#{regexp}.*?)}/x)
  puts $1
  puts '-----'
  return $1 
end

parts = ["name", "description", "usage", "arguments", "value", "details"]
head = "tady bude nejaka fancy hlavicka nebo neco jako html...\n\n\n"

final = head

parts.each do |p|
  temp = get_content(a, p)

  if p.eql? "arguments" then
    final << "<div id=\"#{p}\"><ul>\n" << temp << "\n</ul><\/div>\n" 
  else
    final << "<div id=\"#{p}\">\n" << temp << "\n<\/div>\n" 
  end
end

puts final

