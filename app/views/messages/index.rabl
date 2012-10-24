# app/views/posts/index.rabl
collection @messages
attributes :short_body, :completed_at, :created_at

node('_links') { {:message => {:href => new_message_path}} }


