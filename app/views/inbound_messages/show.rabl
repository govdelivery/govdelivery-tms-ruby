object @message
attributes :from, :to, :body, :created_at

node(:_links) do |m|
  {:self => inbound_message_path(m)}
end

