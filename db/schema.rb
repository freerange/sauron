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

ActiveRecord::Schema.define(:version => 20120511092459) do

  create_table "mail_index", :force => true do |t|
    t.integer  "message_index_id"
    t.string   "account"
    t.string   "uid"
    t.string   "delivered_to"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "mail_index", ["message_index_id"], :name => "index_mail_index_on_message_index_id"

  create_table "message_index", :force => true do |t|
    t.string   "account"
    t.integer  "uid",          :limit => 255
    t.string   "subject"
    t.datetime "date"
    t.string   "from"
    t.string   "message_id"
    t.string   "message_hash"
    t.string   "delivered_to"
    t.string   "in_reply_to"
  end

  add_index "message_index", ["in_reply_to"], :name => "index_message_index_on_in_reply_to"
  add_index "message_index", ["message_hash"], :name => "index_mail_index_on_message_hash"

end
