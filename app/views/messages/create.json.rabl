object  MessagePresenter.new(@message, self)
attributes :id, *@content_attributes, :created_at, :status, :_links

node(:errors, :if => ->(message){ message.errors.any? }) { |message| message.errors }
