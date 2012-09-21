class AddColsToPackages < ActiveRecord::Migration
  def change
    add_column :packages, :description, :text
    add_column :packages, :suggests, :string
    add_column :packages, :imports, :string
    add_column :packages, :maintainers, :string
    add_column :packages, :info_harvested, :boolean, :null => false, :default => false
  end
end
