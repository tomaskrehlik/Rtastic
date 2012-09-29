# == Schema Information
#
# Table name: packages
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  version        :string(255)
#  archive_name   :string(255)
#  depends        :text
#  authors        :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  description    :text
#  suggests       :text
#  imports        :text
#  maintainers    :text
#  info_harvested :boolean          default(FALSE), not null
#

class Package < ActiveRecord::Base
  attr_accessible :archive_name, :authors, :depends, :name, :version, :description, :suggests, :imports, :maintainers,  :info_harvested
  
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :version, presence: true
end
