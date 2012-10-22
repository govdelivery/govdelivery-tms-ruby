object @message
attributes :id, :short_body, :completed_at, :created_at
unless @message.errors.empty?
  node(:errorsl) { |message| message.errors.on_base.to_json }
end
child :recipients do
  attributes :id, :provided_phone, :provided_country_code, :phone, :country_code, :status, :error_message, :created_at, :sent_at, :completed_at
  node(:errorsl) { |recipient| recipient.errors.to_json }
end