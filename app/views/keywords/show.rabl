object @keyword
attributes :name
if @keyword
  unless @keyword.errors.empty?
    node(:errors) { |keyword| keyword.errors }
  end
  node(:actions) do |k|
    k.event_handler.actions.map{|a| {
      :params => a.params.to_hash,
      :action_type => a.action_type,
      :name => a.name
    }}
  end
  node(:_links) do |k|
    {:self => k.persisted? ? keyword_path(k) : keywords_path}
  end
end