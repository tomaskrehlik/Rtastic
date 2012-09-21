module ApplicationHelper
  # Method that handles problems with encodings and regular expressions.
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
end
