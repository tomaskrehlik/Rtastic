class AddColsToPackages < ActiveRecord::Migration
  def change
    add_column :packages, :description, :text
    add_column :packages, :suggests, :text
    add_column :packages, :imports, :text
    add_column :packages, :maintainers, :text
    add_column :packages, :info_harvested, :boolean, :null => false, :default => false
  end
end
