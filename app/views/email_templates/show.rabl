object @template
attributes :id, :uuid, :body, :subject, :link_tracking_parameters,
           :message_type_code,
           :macros, :open_tracking_enabled, :click_tracking_enabled, :created_at

node(:_links) do |e|
  Hash.new.tap do |h|
    h[:self] = e.persisted? ? templates_email_path(e) : templates_email_index_path
    h[:account] = e.persisted?  ? account_path(e.account) : "" if @current_user.admin?
    h[:from_address] = e.persisted? ? from_address_path(e.from_address) : ""
    h[:message_type] = e.persisted? ? message_type_path(e.message_type) : "" if e.message_type
  end
end

if root_object
  unless root_object.errors.empty?
    node(:errors) { |template| template.errors }
  end
end
