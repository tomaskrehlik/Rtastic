class Package < ActiveRecord::Base
  attr_accessible :archive_name, :authors, :depends, :name, :version, :description, :suggests, :imports, :maintainers
  
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :version, presence: true
end
