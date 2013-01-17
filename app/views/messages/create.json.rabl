object View::MessageLinks.new(@message, self)
attributes @content_attribute, :completed_at, :created_at, :_links

node(:errors, :if => ->(message){ message.errors.any? }) { |message| message.errors }
