object @webhook
attributes :url, :event_type

if root_object
  if root_object.errors.any?
    node(:errors) { |webhook| webhook.errors }
  end
end
