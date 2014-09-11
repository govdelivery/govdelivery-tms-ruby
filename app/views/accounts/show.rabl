object @account
attributes :name, :created_at, :updated_at,
           :stop_handler_id, :voice_vendor_id, :email_vendor_id, :sms_vendor_id, :ipaws_vendor_id,
           :help_text, :stop_text, :default_response_text, :dcm_account_codes

node(:_links) do |a|
  {:self => a.persisted? ? account_path(a) : accounts_path}
end