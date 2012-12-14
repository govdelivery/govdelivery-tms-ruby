object @message
attributes :short_body, :url, :completed_at, :created_at
if @message
  unless @message.errors.empty?
    node(:errors) { |message| message.errors }
  end

  child :recipients => 'recipients' do
    attributes :formatted_phone, :phone, :status, :created_at, :sent_at, :completed_at
    node(:error_message, :unless => lambda { |r| r.error_message.nil? }) do |r|
      r.error_message
    end
    node(:errors, :unless => lambda { |r| r.valid? }) { |recipient| recipient.errors }
  end

  node(:_links) do |m|
    {:self => m.persisted? ? message_path(m) : messages_path}
  end
end