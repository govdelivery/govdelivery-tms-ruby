object false

node(:'_links') do
  [
    {:self => root_path},
    {:messages => messages_path},
  ]
end
