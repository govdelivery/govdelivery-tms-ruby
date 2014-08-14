object @webhook
attributes :url, :event_type

if root_object
  if root_object.errors.any?
    node(:errors) { |webhook| webhook.errors }
  end

  unless root_object.new?
    attribute :recipient_counts
  end
end
