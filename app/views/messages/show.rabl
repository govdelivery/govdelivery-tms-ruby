object MessagePresenter.new(@message, self)
attributes *@content_attributes, :created_at, :status, :_links

if root_object
  unless root_object.errors.empty?
    node(:errors) { |message| message.errors }
  end

  unless root_object.new?
    attribute :recipient_counts
  end

end
