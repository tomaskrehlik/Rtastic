class CreateDocumentations < ActiveRecord::Migration
  def change
    create_table :documentations do |t|
      t.text :package
      t.text :function
      t.text :arguments
      t.text :author
      t.text :concept
      t.text :description
      t.text :details
      t.text :docType
      t.text :encoding
      t.text :format
      t.text :keyword
      t.text :note
      t.text :references
      t.text :section
      t.text :seealso
      t.text :source
      t.text :title
      t.text :value
      t.text :examples
      t.text :usage
      t.text :alias
      t.text :Rdversion
      t.text :synopsis

      t.timestamps
    end
  end
end
