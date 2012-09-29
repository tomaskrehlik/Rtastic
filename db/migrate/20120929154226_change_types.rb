class ChangeTypes < ActiveRecord::Migration
  def change
    change_column :documentations, :format
  end
  def up
  end

  def down
  end
end
