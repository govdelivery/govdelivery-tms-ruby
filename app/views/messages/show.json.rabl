object @message
attributes :short_body, :completed_at, :created_at
unless @message.errors.empty?
  node(:errors) { |message| message.errors }
end
node(:_links) do |m|
  {:self => m.persisted? ? message_path(m) : messages_path}
end
child :recipients do
  attributes :provided_phone, :provided_country_code, :phone, :country_code, :status, :created_at, :sent_at, :completed_at
  node(:error_message, :unless => lambda { |r| r.error_message.nil? }) do |r|
    r.error_message
  end
  node(:errors, :unless => lambda { |r| r.valid? }) { |recipient| recipient.errors }
end unless @message.recipients.empty?
