# app/views/posts/index.rabl
collection @messages.map{|m| View::MessageLinks.new(m, self)}
attributes @content_attribute, :completed_at, :created_at, :_links

node(:errors, :if => ->(message){ message.errors.any? }) { |message| message.errors }
