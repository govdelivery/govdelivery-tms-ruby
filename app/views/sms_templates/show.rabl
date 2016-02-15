object @template
attributes :id, :uuid, :body, :created_at

node(:_links) do |e|
  Hash.new.tap do |h|
    h[:self] = e.persisted? ? templates_sms_path(e) : templates_sms_index_path
    h[:account] = e.persisted?  ? account_path(e.account) : "" if @current_user.admin?
  end
end
