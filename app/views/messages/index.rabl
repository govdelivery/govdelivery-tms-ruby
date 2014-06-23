collection @messages.map{|m|  MessagePresenter.new(m, self)}
attributes *@content_attributes, :created_at, :status, :_links

node(:errors, :if => ->(message){ message.errors.any? }) { |message| message.errors }
