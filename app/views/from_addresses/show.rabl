object @from_address
attributes :from_email, :reply_to_email, :bounce_email, :is_default, :created_at

if root_object
  if root_object.errors.any?
    node(:errors) { |obj| obj.errors }
  end
  node(:_links) do |obj|
    {:self => obj.persisted? ? from_address_path(obj) : from_address_path}
  end
end