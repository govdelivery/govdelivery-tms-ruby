object @message
attributes :short_body, :url, :completed_at, :created_at
if @message
  unless @message.errors.empty?
    node(:errors) { |message| message.errors }
  end

  node(:_links) do |m|
    {:self => m.persisted? ? message_path(m) : messages_path,
     :recipients => message_recipients_path(m)}
  end
end