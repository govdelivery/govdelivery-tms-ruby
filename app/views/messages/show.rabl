object MessagePresenter.new(@message, self)
attributes *@content_attributes, :created_at, :status, :_links

if root_object
  unless root_object.errors.empty?
    node(:errors) { |message| message.errors }
  end

  if root_object.status != Message::Status::NEW
    attribute :recipient_counts
  end

end
