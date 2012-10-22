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

ActiveRecord::Schema.define(:version => 20121018213317) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.integer  "vendor_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "messages", :force => true do |t|
    t.integer  "user_id"
    t.string   "short_body"
    t.time     "completed_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "recipients", :force => true do |t|
    t.integer  "message_id"
    t.string   "phone"
    t.string   "country_code"
    t.string   "provided_phone"
    t.string   "provided_country_code"
    t.string   "ack"
    t.string   "status"
    t.string   "error_message",         :limit => 512
    t.time     "sent_at"
    t.time     "completed_at"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "recipients", ["message_id"], :name => "index_recipients_on_message_id"

  create_table "users", :force => true do |t|
    t.integer  "account_id"
    t.string   "email"
    t.string   "encrypted_password"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

  create_table "vendors", :force => true do |t|
    t.string   "name"
    t.string   "username"
    t.string   "password"
    t.string   "from"
    t.string   "worker",     :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
