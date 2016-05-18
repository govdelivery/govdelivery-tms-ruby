object @message_type
attributes :name, :name_key, :created_at

if root_object
  if root_object.errors.any?
    node(:errors) { |message_type| message_type.errors }
  end
end

node(:'_links') do |w|
  {:self => w.persisted? ? message_type_path(w) : message_types_path}
end
