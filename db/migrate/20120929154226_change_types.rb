class ChangeTypes < ActiveRecord::Migration
  
  def change
    change_column :documentations, :Rdversion, :text
    change_column :documentations, :alias, :text
    change_column :documentations, :encoding, :text
    change_column :documentations, :format, :text
  end

end
