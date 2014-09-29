object @webhook
attributes :url, :event_type, :created_at

if root_object
  if root_object.errors.any?
    node(:errors) { |webhook| webhook.errors }
  end
end

node(:'_links') do |w|
  {:self => w.persisted? ? webhook_path(w) : webhooks_path}
end
