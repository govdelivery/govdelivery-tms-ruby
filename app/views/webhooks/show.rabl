object @webhook
attributes :url, :event_type, :created_at

if root_object
  if root_object.errors.any?
    node(:errors) { |webhook| webhook.errors }
  end
end

node(:'_links') do |w|
  links = {:self => webhook_path(w)}
end