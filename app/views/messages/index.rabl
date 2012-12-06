# app/views/posts/index.rabl
collection @messages
attributes :body, :completed_at, :created_at

node('_links') { |m| {:self => message_path(m)} }


