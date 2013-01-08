# app/views/posts/index.rabl
collection @messages
extends "messages/show"

node('_links') { |m| {:self => send("#{controller_name.singularize}_path",m)} }
