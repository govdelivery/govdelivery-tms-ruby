# app/views/posts/index.rabl
collection @messages
attributes :body, :from, :created_at, :to

node('_links') { |m| {:self => url_for(:controller => 'inbound_messages', :action => 'show', :id => m.id)} }


