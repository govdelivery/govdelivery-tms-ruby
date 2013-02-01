object View::MessageLinks.new(@message, self)
attributes *@content_attributes, :created_at, :_links

node(:errors, :if => ->(message){ message.errors.any? }) { |message| message.errors }
