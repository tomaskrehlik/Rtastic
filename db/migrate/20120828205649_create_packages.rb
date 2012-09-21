class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :name
      t.string :version
      t.string :archive_name
      t.string :depends
      t.string :authors

      t.timestamps
    end
  end
end
