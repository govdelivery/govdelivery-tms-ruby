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

ActiveRecord::Schema.define(:version => 20121130195810) do

  create_table "accounts", :force => true do |t|
    t.string   "name",            :null => false
    t.integer  "vendor_id",       :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "stop_handler_id"
  end

  create_table "actions", :force => true do |t|
    t.integer  "account_id",                       :null => false
    t.integer  "action_type",                      :null => false
    t.string   "name"
    t.string   "params",           :limit => 4000
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "event_handler_id"
  end

  create_table "event_handlers", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "inbound_messages", :force => true do |t|
    t.integer  "vendor_id"
    t.string   "from_phone"
    t.string   "body",       :limit => 300
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "keywords", :force => true do |t|
    t.integer  "account_id"
    t.string   "name",             :limit => 160, :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "vendor_id"
    t.integer  "event_handler_id"
  end

  add_index "keywords", ["vendor_id", "name"], :name => "index_keywords_on_vendor_id_and_name", :unique => true

  create_table "messages", :force => true do |t|
    t.integer  "user_id",      :null => false
    t.string   "short_body",   :null => false
    t.time     "completed_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "recipients", :force => true do |t|
    t.integer  "message_id",                                    :null => false
    t.integer  "vendor_id",                                     :null => false
    t.string   "phone"
    t.string   "formatted_phone"
    t.string   "ack"
    t.integer  "status",                         :default => 1, :null => false
    t.string   "error_message",   :limit => 512
    t.time     "sent_at"
    t.time     "completed_at"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "recipients", ["ack"], :name => "index_recipients_on_ack"
  add_index "recipients", ["message_id"], :name => "index_recipients_on_message_id"

  create_table "stop_requests", :force => true do |t|
    t.integer  "vendor_id",  :null => false
    t.string   "phone",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "stop_requests", ["vendor_id", "phone"], :name => "index_stop_requests_on_vendor_id_and_phone", :unique => true

  create_table "users", :force => true do |t|
    t.integer  "account_id",                            :null => false
    t.string   "email",                                 :null => false
    t.string   "encrypted_password",                    :null => false
    t.boolean  "admin",              :default => false
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

  create_table "vendors", :force => true do |t|
    t.string   "name",                                                               :null => false
    t.string   "username",                                                           :null => false
    t.string   "password",                                                           :null => false
    t.string   "from",                                                               :null => false
    t.string   "worker",                                                             :null => false
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
    t.string   "help_text",  :default => "Go to http://bit.ly/govdhelp for help",    :null => false
    t.string   "stop_text",  :default => "You will no longer receive SMS messages.", :null => false
  end

end
