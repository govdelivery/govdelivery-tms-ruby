collection @messages.map{|m|  MessagePresenter.new(m, self)}
attributes :id, *@content_attributes, :created_at, :message_type_code, :status, :_links

node(:errors, :if => ->(message){ message.errors.any? }) { |message| message.errors }
