# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120929154226) do

  create_table "documentations", :force => true do |t|
    t.text     "package"
    t.text     "name"
    t.text     "arguments"
    t.text     "author"
    t.text     "concept"
    t.text     "description"
    t.text     "details"
    t.text     "docType"
    t.text     "encoding"
    t.text     "format"
    t.text     "keyword"
    t.text     "note"
    t.text     "references"
    t.text     "section"
    t.text     "seealso"
    t.text     "source"
    t.text     "title"
    t.text     "value"
    t.text     "examples"
    t.text     "usage"
    t.text     "alias"
    t.text     "Rdversion"
    t.text     "synopsis"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "packages", :force => true do |t|
    t.string   "name"
    t.string   "version"
    t.string   "archive_name"
    t.text     "depends"
    t.text     "authors"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.text     "description"
    t.text     "suggests"
    t.text     "imports"
    t.text     "maintainers"
    t.boolean  "info_harvested", :default => false, :null => false
  end

  create_table "packageupdateloggers", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
