object @keyword
attributes :name
if @keyword
  unless @keyword.errors.empty?
    node(:errors) { |keyword| keyword.errors }
  end
  node(:_links) do |k|
    {:self => k.persisted? ? keyword_path(k) : keywords_path}
  end
end