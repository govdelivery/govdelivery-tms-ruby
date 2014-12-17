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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141217184138) do

  create_table "accounts", force: true do |t|
    t.string   "name",                                                        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "voice_vendor_id",                    precision: 38, scale: 0
    t.integer  "email_vendor_id",                    precision: 38, scale: 0
    t.integer  "sms_vendor_id",                      precision: 38, scale: 0
    t.string   "dcm_account_codes",     limit: 4000
    t.integer  "ipaws_vendor_id",                    precision: 38, scale: 0
    t.string   "default_response_text"
    t.string   "sid",                   limit: 32,                            null: false
    t.string   "link_encoder",          limit: 30
  end

  create_table "authentication_tokens", force: true do |t|
    t.integer  "user_id",    precision: 38, scale: 0, null: false
    t.string   "token",                               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authentication_tokens", ["token"], name: "i_authentication_tokens_token", unique: true, tablespace: "tsms_indx01"

  create_table "call_scripts", force: true do |t|
    t.integer  "voice_message_id",              precision: 38, scale: 0
    t.string   "say_text",         limit: 1000
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "command_actions", force: true do |t|
    t.integer  "command_id",                     precision: 38, scale: 0
    t.integer  "inbound_message_id",             precision: 38, scale: 0
    t.integer  "status",                         precision: 38, scale: 0
    t.string   "content_type",       limit: 100
    t.string   "response_body",      limit: 500
    t.datetime "created_at",                                              null: false
  end

  create_table "commands", force: true do |t|
    t.string   "name"
    t.string   "params",       limit: 4000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "command_type",                                       null: false
    t.integer  "keyword_id",                precision: 38, scale: 0
  end

  add_index "commands", ["keyword_id"], name: "index_commands_on_keyword_id", tablespace: "tsms_indx01"

  create_table "email_messages", force: true do |t|
    t.integer  "user_id",                            precision: 38, scale: 0
    t.integer  "account_id",                         precision: 38, scale: 0,                 null: false
    t.text     "body"
    t.string   "status",                                                      default: "new", null: false
    t.string   "from_name"
    t.string   "subject",                limit: 400
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ack"
    t.datetime "sent_at"
    t.boolean  "open_tracking_enabled",              precision: 1,  scale: 0, default: true
    t.boolean  "click_tracking_enabled",             precision: 1,  scale: 0, default: true
    t.text     "macros"
    t.string   "from_email"
    t.string   "reply_to"
    t.string   "errors_to"
  end

  add_index "email_messages", ["user_id", "created_at", "status", "subject", "id"], name: "em_idx4", tablespace: "tsms_indx01"

  create_table "email_recipient_clicks", force: true do |t|
    t.integer  "email_message_id",                precision: 38, scale: 0, null: false
    t.integer  "email_recipient_id",              precision: 38, scale: 0, null: false
    t.string   "email",              limit: 256,                           null: false
    t.string   "url",                limit: 4000,                          null: false
    t.datetime "clicked_at",                                               null: false
    t.datetime "created_at",                                               null: false
  end

  add_index "email_recipient_clicks", ["email_message_id", "email_recipient_id", "id", "clicked_at"], name: "erc_idx1", tablespace: "tsms_indx01"
  add_index "email_recipient_clicks", ["email_message_id", "email_recipient_id"], name: "i922bea928d6001e8d90c6daf89654", tablespace: "tsms_indx01"

  create_table "email_recipient_opens", force: true do |t|
    t.integer  "email_message_id",               precision: 38, scale: 0, null: false
    t.integer  "email_recipient_id",             precision: 38, scale: 0, null: false
    t.string   "event_ip",                                                null: false
    t.string   "email",              limit: 256,                          null: false
    t.datetime "opened_at",                                               null: false
    t.datetime "created_at",                                              null: false
  end

  add_index "email_recipient_opens", ["email_message_id", "email_recipient_id", "id", "opened_at"], name: "ero_idx1", tablespace: "tsms_indx01"
  add_index "email_recipient_opens", ["email_message_id", "email_recipient_id"], name: "i46e4b3758023b96cabd6e28d7f0bc", tablespace: "tsms_indx01"

  create_table "email_recipients", force: true do |t|
    t.integer  "message_id",                precision: 38, scale: 0,                 null: false
    t.integer  "vendor_id",                 precision: 38, scale: 0
    t.string   "ack"
    t.string   "email"
    t.string   "status",                                             default: "new", null: false
    t.string   "error_message", limit: 512
    t.datetime "sent_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "macros"
  end

  add_index "email_recipients", ["message_id", "id"], name: "i_ema_rec_mes_id_id", tablespace: "tsms_indx01"

  create_table "email_vendors", force: true do |t|
    t.string   "name",                null: false
    t.string   "worker",              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "deliveries_sequence"
    t.string   "clicks_sequence"
    t.string   "opens_sequence"
  end

  create_table "from_addresses", force: true do |t|
    t.integer  "account_id",     precision: 38, scale: 0
    t.string   "from_email"
    t.string   "reply_to_email"
    t.string   "bounce_email"
    t.datetime "created_at"
    t.boolean  "is_default",     precision: 1,  scale: 0, default: false
  end

  create_table "inbound_messages", force: true do |t|
    t.integer  "vendor_id",                    precision: 38, scale: 0
    t.string   "caller_phone"
    t.string   "body",             limit: 300
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "vendor_phone",     limit: 100
    t.integer  "keyword_id",                   precision: 38, scale: 0
    t.string   "keyword_response"
    t.string   "command_status",   limit: 15
    t.integer  "account_id",                   precision: 38, scale: 0
  end

  add_index "inbound_messages", ["account_id"], name: "i_inbound_messages_account_id", tablespace: "tsms_indx01"

  create_table "ipaws_vendors", force: true do |t|
    t.integer  "cog_id",                     precision: 38, scale: 0, null: false
    t.string   "user_id",                                             null: false
    t.text     "public_password_encrypted",                           null: false
    t.text     "private_password_encrypted",                          null: false
    t.binary   "jks",                                                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "keywords", force: true do |t|
    t.integer  "account_id",                precision: 38, scale: 0
    t.string   "name",          limit: 160,                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "response_text", limit: 160
  end

  create_table "sms_messages", force: true do |t|
    t.string   "body"
    t.datetime "created_at"
    t.datetime "completed_at"
    t.integer  "user_id",       precision: 38, scale: 0
    t.integer  "account_id",    precision: 38, scale: 0,                 null: false
    t.string   "status",                                 default: "new", null: false
    t.datetime "sent_at"
    t.integer  "sms_vendor_id", precision: 38, scale: 0,                 null: false
  end

  create_table "sms_prefixes", force: true do |t|
    t.string   "prefix",                                 null: false
    t.integer  "account_id",    precision: 38, scale: 0, null: false
    t.integer  "sms_vendor_id", precision: 38, scale: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sms_recipients", force: true do |t|
    t.integer  "message_id",                  precision: 38, scale: 0,                 null: false
    t.integer  "vendor_id",                   precision: 38, scale: 0,                 null: false
    t.string   "phone",                                                                null: false
    t.string   "formatted_phone"
    t.string   "ack"
    t.string   "error_message",   limit: 512
    t.datetime "sent_at"
    t.datetime "completed_at"
    t.string   "status",                                               default: "new", null: false
    t.datetime "created_at"
  end

  add_index "sms_recipients", ["message_id", "id"], name: "i_sms_recipients_message_id_id", tablespace: "tsms_indx01"

  create_table "sms_vendors", force: true do |t|
    t.string   "name",                                                                                                                                                                             null: false
    t.string   "username",                                                                                                                                                                         null: false
    t.string   "password",                                                                                                                                                                         null: false
    t.string   "from_phone",                                                                                                                                                                       null: false
    t.string   "worker",                                                                                                                                                                           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "help_text",                                     default: "This service is provided by GovDelivery. If you are a customer in need of assistance, please contact customer support.", null: false
    t.string   "stop_text",                                     default: "You will no longer receive SMS messages.",                                                                               null: false
    t.boolean  "shared",                precision: 1, scale: 0, default: false,                                                                                                                    null: false
    t.string   "default_response_text"
    t.string   "start_text"
  end

  add_index "sms_vendors", ["from_phone"], name: "i_sms_vendors_from_phone", unique: true, tablespace: "tsms_indx01"

  create_table "stop_requests", force: true do |t|
    t.integer  "vendor_id",  precision: 38, scale: 0, null: false
    t.string   "phone",                               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id", precision: 38, scale: 0
  end

  add_index "stop_requests", ["vendor_id", "account_id", "phone"], name: "i_sto_req_ven_id_acc_id_pho", unique: true, tablespace: "tsms_indx01"

  create_table "transformers", force: true do |t|
    t.integer  "account_id",        precision: 38, scale: 0
    t.string   "transformer_class"
    t.string   "content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.integer  "account_id",         precision: 38, scale: 0,                 null: false
    t.string   "email",                                                       null: false
    t.string   "encrypted_password",                                          null: false
    t.boolean  "admin",              precision: 1,  scale: 0, default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, tablespace: "tsms_indx01"

  create_table "voice_messages", force: true do |t|
    t.string   "play_url",     limit: 512
    t.datetime "created_at"
    t.datetime "completed_at"
    t.integer  "user_id",                   precision: 38, scale: 0
    t.integer  "account_id",                precision: 38, scale: 0,                 null: false
    t.string   "status",                                             default: "new", null: false
    t.datetime "sent_at"
    t.string   "say_text",     limit: 1000
  end

  create_table "voice_recipients", force: true do |t|
    t.integer  "message_id",                  precision: 38, scale: 0,                 null: false
    t.integer  "vendor_id",                   precision: 38, scale: 0
    t.string   "phone"
    t.string   "formatted_phone"
    t.string   "ack"
    t.string   "error_message",   limit: 512
    t.datetime "sent_at"
    t.datetime "completed_at"
    t.string   "status",                                               default: "new", null: false
    t.datetime "created_at"
  end

  add_index "voice_recipients", ["message_id", "id"], name: "i_voi_rec_mes_id_id", tablespace: "tsms_indx01"

  create_table "voice_vendors", force: true do |t|
    t.string   "name",       null: false
    t.string   "username",   null: false
    t.string   "password",   null: false
    t.string   "from_phone", null: false
    t.string   "worker",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "webhooks", force: true do |t|
    t.integer  "account_id",            precision: 38, scale: 0
    t.string   "event_type", limit: 30
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
