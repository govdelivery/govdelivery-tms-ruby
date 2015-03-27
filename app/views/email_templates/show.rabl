object @email_template
attributes :id, :body, :subject, :link_tracking_parameters,
           :macros, :open_tracking_enabled, :click_tracking_enabled, :created_at

node(:_links) do |e|
  {:self => e.persisted? ? email_template_path(e) : email_template_path,
   :account => e.persisted? ? account_path(e.account) : "",
   :from_address => e.persisted? ? from_address_path(e.from_address) : ""}
end