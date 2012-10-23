# app/views/posts/index.rabl
collection @messages
attributes :short_body, :completed_at, :created_at

node('_links') { |message| {:self => {:href => message_path(message)}} }


