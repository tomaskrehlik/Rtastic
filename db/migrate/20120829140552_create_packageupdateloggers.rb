class CreatePackageupdateloggers < ActiveRecord::Migration
  def change
    create_table :packageupdateloggers do |t|

      t.timestamps
    end
  end
end
