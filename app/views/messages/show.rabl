object View::MessageLinks.new(@message, self)
attributes *@content_attributes, :completed_at, :created_at, :_links, :status

if root_object
  unless root_object.errors.empty?
    node(:errors) { |message| message.errors }
  end

  if root_object.status != Message::Status::NEW
    attribute :recipient_counts
  end

end
