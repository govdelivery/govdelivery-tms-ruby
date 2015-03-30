object @account
attributes :name, :created_at, :updated_at,
           :voice_vendor_id, :email_vendor_id, :sms_vendor_id, :ipaws_vendor_id,
           :help_text, :stop_text, :default_response_text, :link_tracking_parameters,
           :dcm_account_codes, :sid

node(:_links) do |a|
  {:self => a.persisted? ? account_path(a) : accounts_path,
   :users => a.persisted? ? account_users_path(a) : ""}
end