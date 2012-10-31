# app/views/posts/index.rabl
collection @messages
attributes :body, :from, :created_at, :to

node('_links') { |m| {:self => inbound_message_path(m)} }


