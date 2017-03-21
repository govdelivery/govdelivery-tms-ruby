object @login
attributes :url
node(:_links) do |k|
  {:self => 'user/login'}
end
