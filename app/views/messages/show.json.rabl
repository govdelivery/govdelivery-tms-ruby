object @message
attributes :short_body, :completed_at, :created_at
unless @message.errors.empty?
  node(:errors) { |message| message.errors }
end
node(:_links, :if => lambda { |m| m.valid? }) do |m|
  {:self => message_path(m)}
end
child :recipients do
  attributes :provided_phone, :provided_country_code, :phone, :country_code, :status, :error_message, :created_at, :sent_at, :completed_at
  node(:errors, :unless => lambda { |r| r.valid?}) { |recipient| recipient.errors }
end unless @message.recipients.empty?
