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

ActiveRecord::Schema.define(version: 20160516175947) do

  create_table "accounts", force: :cascade do |t|
    t.string   "name",                                  null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "voice_vendor_id",          limit: nil
    t.integer  "email_vendor_id",          limit: nil
    t.integer  "sms_vendor_id",            limit: nil
    t.string   "dcm_account_codes",        limit: 4000
    t.integer  "ipaws_vendor_id",          limit: nil
    t.string   "default_response_text"
    t.string   "sid",                      limit: 32,   null: false
    t.string   "link_encoder",             limit: 30
    t.string   "link_tracking_parameters"
  end

  create_table "authentication_tokens", force: :cascade do |t|
    t.integer  "user_id",    limit: nil, null: false
    t.string   "token",                  null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "authentication_tokens", ["token"], name: "i_authentication_tokens_token", unique: true, tablespace: "tsms_indx01"

  create_table "call_scripts", force: :cascade do |t|
    t.integer  "voice_message_id", limit: nil
    t.string   "say_text",         limit: 1000
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "command_actions", force: :cascade do |t|
    t.integer  "command_id",         limit: nil
    t.integer  "inbound_message_id", limit: nil
    t.integer  "status",                         precision: 38
    t.string   "content_type",       limit: 100
    t.string   "response_body",      limit: 500
    t.datetime "created_at",                                    null: false
    t.string   "error_message"
  end

  create_table "commands", force: :cascade do |t|
    t.string   "name"
    t.string   "params",       limit: 4000
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "command_type",              null: false
    t.integer  "keyword_id",   limit: nil
  end

  add_index "commands", ["keyword_id"], name: "index_commands_on_keyword_id", tablespace: "tsms_indx01"

  create_table "email_messages", force: :cascade do |t|
    t.integer  "user_id",                limit: nil
    t.integer  "account_id",             limit: nil,                 null: false
    t.text     "body"
    t.string   "status",                             default: "new", null: false
    t.string   "from_name"
    t.string   "subject",                limit: 400
    t.datetime "completed_at"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "ack"
    t.datetime "sent_at"
    t.boolean  "open_tracking_enabled",  limit: nil
    t.boolean  "click_tracking_enabled", limit: nil
    t.text     "macros"
    t.string   "from_email"
    t.string   "reply_to"
    t.string   "errors_to"
    t.integer  "email_template_id",      limit: nil
    t.integer  "message_type_id",        limit: nil
  end

  add_index "email_messages", ["account_id", "id"], name: "em_inv_idx1", tablespace: "tsms_indx01"
  add_index "email_messages", ["email_template_id"], name: "i_ema_mes_ema_tem_id", tablespace: "tsms_indx01"
  add_index "email_messages", ["message_type_id"], name: "i_ema_mes_mes_typ_id", tablespace: "tsms_indx01"
  add_index "email_messages", ["user_id", "created_at", "status", "subject", "id"], name: "em_idx3", tablespace: "tsms_indx01"

  create_table "email_recipient_clicks", force: :cascade do |t|
    t.integer  "email_message_id",   limit: nil,  null: false
    t.integer  "email_recipient_id", limit: nil,  null: false
    t.string   "email",              limit: 256,  null: false
    t.string   "url",                limit: 4000, null: false
    t.datetime "clicked_at",                      null: false
    t.datetime "created_at",                      null: false
  end

  add_index "email_recipient_clicks", ["email_message_id", "email_recipient_id", "id", "clicked_at"], name: "erc_idx1", tablespace: "tsms_indx01"
  add_index "email_recipient_clicks", ["email_message_id", "email_recipient_id"], name: "i922bea928d6001e8d90c6daf89654", tablespace: "tsms_indx01"

  create_table "email_recipient_opens", force: :cascade do |t|
    t.integer  "email_message_id",   limit: nil, null: false
    t.integer  "email_recipient_id", limit: nil, null: false
    t.string   "event_ip",                       null: false
    t.string   "email",              limit: 256, null: false
    t.datetime "opened_at",                      null: false
    t.datetime "created_at",                     null: false
  end

  add_index "email_recipient_opens", ["email_message_id", "created_at"], name: "ero_inv_idx1", tablespace: "tsms_indx01"
  add_index "email_recipient_opens", ["email_message_id", "email_recipient_id", "id", "opened_at"], name: "ero_idx1", tablespace: "tsms_indx01"
  add_index "email_recipient_opens", ["email_message_id", "email_recipient_id"], name: "i46e4b3758023b96cabd6e28d7f0bc", tablespace: "tsms_indx01"

  create_table "email_recipients", force: :cascade do |t|
    t.integer  "message_id",    limit: nil,                 null: false
    t.integer  "vendor_id",     limit: nil
    t.string   "ack"
    t.string   "email"
    t.string   "status",                    default: "new", null: false
    t.string   "error_message", limit: 512
    t.datetime "sent_at"
    t.datetime "completed_at"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.text     "macros"
  end

  add_index "email_recipients", ["message_id", "id"], name: "i_ema_rec_mes_id_id", tablespace: "tsms_indx01"

  create_table "email_templates", force: :cascade do |t|
    t.text     "body",                                 null: false
    t.string   "subject",                              null: false
    t.string   "link_tracking_parameters"
    t.text     "macros"
    t.integer  "user_id",                  limit: nil
    t.integer  "account_id",               limit: nil
    t.integer  "from_address_id",          limit: nil
    t.boolean  "open_tracking_enabled",    limit: nil, null: false
    t.boolean  "click_tracking_enabled",   limit: nil, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uuid"
  end

  add_index "email_templates", ["account_id", "uuid"], name: "i_ema_tem_acc_id_uui", unique: true, tablespace: "tsms_indx01"

  create_table "email_vendors", force: :cascade do |t|
    t.string   "name",                null: false
    t.string   "worker",              null: false
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "deliveries_sequence"
    t.string   "clicks_sequence"
    t.string   "opens_sequence"
  end

  create_table "from_addresses", force: :cascade do |t|
    t.integer  "account_id",     limit: nil
    t.string   "from_email"
    t.string   "reply_to_email"
    t.string   "bounce_email"
    t.datetime "created_at"
    t.boolean  "is_default",     limit: nil, default: false
  end

  create_table "from_numbers", force: :cascade do |t|
    t.integer  "account_id",   limit: nil
    t.string   "phone_number"
    t.datetime "created_at"
    t.boolean  "is_default",   limit: nil, default: false
  end

  create_table "inbound_messages", force: :cascade do |t|
    t.integer  "vendor_id",        limit: nil
    t.string   "caller_phone"
    t.string   "body",             limit: 300
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "vendor_phone",     limit: 100
    t.integer  "keyword_id",       limit: nil
    t.string   "keyword_response"
    t.string   "command_status",   limit: 15
    t.integer  "account_id",       limit: nil
  end

  add_index "inbound_messages", ["account_id"], name: "i_inbound_messages_account_id", tablespace: "tsms_indx01"

  create_table "incoming_voice_messages", force: :cascade do |t|
    t.integer  "from_number_id", limit: nil
    t.string   "play_url",       limit: 512
    t.string   "say_text",       limit: 1000
    t.boolean  "is_default",     limit: nil,                 default: false, null: false
    t.integer  "expires_in",                  precision: 38
    t.datetime "created_at"
  end

  create_table "ipaws_vendors", force: :cascade do |t|
    t.integer  "cog_id",                     limit: nil, null: false
    t.string   "user_id",                                null: false
    t.text     "public_password_encrypted",              null: false
    t.text     "private_password_encrypted",             null: false
    t.binary   "jks",                                    null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "keywords", force: :cascade do |t|
    t.integer  "account_id",    limit: nil, null: false
    t.string   "name",          limit: 160, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "response_text", limit: 160
  end

  create_table "message_types", force: :cascade do |t|
    t.integer "account_id", limit: nil, null: false
    t.string  "name",                   null: false
    t.string  "name_key",               null: false
  end

  create_table "sms_messages", force: :cascade do |t|
    t.string   "body"
    t.datetime "created_at"
    t.datetime "completed_at"
    t.integer  "user_id",         limit: nil
    t.integer  "account_id",      limit: nil,                 null: false
    t.string   "status",                      default: "new", null: false
    t.datetime "sent_at"
    t.integer  "sms_vendor_id",   limit: nil,                 null: false
    t.integer  "sms_template_id", limit: nil
  end

  add_index "sms_messages", ["sms_template_id"], name: "i_sms_messages_sms_template_id", tablespace: "tsms_indx01"

  create_table "sms_prefixes", force: :cascade do |t|
    t.string   "prefix",                    null: false
    t.integer  "account_id",    limit: nil, null: false
    t.integer  "sms_vendor_id", limit: nil, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "sms_recipients", force: :cascade do |t|
    t.integer  "message_id",      limit: nil,                 null: false
    t.integer  "vendor_id",       limit: nil,                 null: false
    t.string   "phone",                                       null: false
    t.string   "formatted_phone"
    t.string   "ack"
    t.string   "error_message",   limit: 512
    t.datetime "sent_at"
    t.datetime "completed_at"
    t.string   "status",                      default: "new", null: false
    t.datetime "created_at"
  end

  add_index "sms_recipients", ["message_id", "id"], name: "i_sms_recipients_message_id_id", tablespace: "tsms_indx01"

  create_table "sms_templates", force: :cascade do |t|
    t.text     "body",                   null: false
    t.integer  "user_id",    limit: nil
    t.integer  "account_id", limit: nil
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uuid"
  end

  add_index "sms_templates", ["account_id", "uuid"], name: "i_sms_tem_acc_id_uui", unique: true, tablespace: "tsms_indx01"

  create_table "sms_vendors", force: :cascade do |t|
    t.string   "name",                                                                                                                                                     null: false
    t.string   "username",                                                                                                                                                 null: false
    t.string   "password",                                                                                                                                                 null: false
    t.string   "from_phone",                                                                                                                                               null: false
    t.string   "worker",                                                                                                                                                   null: false
    t.datetime "created_at",                                                                                                                                               null: false
    t.datetime "updated_at",                                                                                                                                               null: false
    t.string   "help_text",             default: "This service is provided by GovDelivery. If you are a customer in need of assistance, please contact customer support.", null: false
    t.string   "stop_text",             default: "You will no longer receive SMS messages.",                                                                               null: false
    t.string   "default_response_text"
    t.string   "start_text"
  end

  add_index "sms_vendors", ["from_phone"], name: "i_sms_vendors_from_phone", unique: true, tablespace: "tsms_indx01"

  create_table "stop_requests", force: :cascade do |t|
    t.integer  "vendor_id",  limit: nil, null: false
    t.string   "phone",                  null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "account_id", limit: nil
  end

  add_index "stop_requests", ["vendor_id", "account_id", "phone"], name: "i_sto_req_ven_id_acc_id_pho", unique: true, tablespace: "tsms_indx01"

  create_table "users", force: :cascade do |t|
    t.integer  "account_id",         limit: nil,                 null: false
    t.string   "email",                                          null: false
    t.string   "encrypted_password",                             null: false
    t.boolean  "admin",              limit: nil, default: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, tablespace: "tsms_indx01"

  create_table "voice_messages", force: :cascade do |t|
    t.string   "play_url",     limit: 512
    t.datetime "created_at"
    t.datetime "completed_at"
    t.integer  "user_id",      limit: nil
    t.integer  "account_id",   limit: nil,                                 null: false
    t.string   "status",                                   default: "new", null: false
    t.datetime "sent_at"
    t.string   "say_text",     limit: 1000
    t.integer  "max_retries",               precision: 38, default: 0,     null: false
    t.integer  "retry_delay",               precision: 38, default: 300,   null: false
    t.string   "from_number"
  end

  create_table "voice_recipient_attempts", force: :cascade do |t|
    t.integer  "voice_message_id",   limit: nil, null: false
    t.integer  "voice_recipient_id", limit: nil, null: false
    t.datetime "completed_at"
    t.string   "ack"
    t.string   "description",        limit: 50
  end

  create_table "voice_recipients", force: :cascade do |t|
    t.integer  "message_id",      limit: nil,                 null: false
    t.integer  "vendor_id",       limit: nil
    t.string   "phone"
    t.string   "formatted_phone"
    t.string   "ack"
    t.string   "error_message",   limit: 512
    t.datetime "sent_at"
    t.datetime "completed_at"
    t.string   "status",                      default: "new", null: false
    t.datetime "created_at"
  end

  add_index "voice_recipients", ["message_id", "id"], name: "i_voi_rec_mes_id_id", tablespace: "tsms_indx01"

  create_table "voice_vendors", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "username",   null: false
    t.string   "password",   null: false
    t.string   "worker",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "webhooks", force: :cascade do |t|
    t.integer  "account_id", limit: nil
    t.string   "event_type", limit: 30
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
