class ChangeFunctionName < ActiveRecord::Migration
  def change
    rename_column :documentations, :function, :name
  end
  def up
  end

  def down
  end
end
