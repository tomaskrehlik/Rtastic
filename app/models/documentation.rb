class Documentation < ActiveRecord::Base
  attr_accessible :Rdversion, :alias, :arguments, :author, :concept, :description, :details, :docType, :encoding, :examples, :format, :name, :keyword, :note, :package, :references, :section, :seealso, :source, :synopsis, :title, :usage, :value
end
