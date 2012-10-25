object false

node(:'_links') do
  [
    {:self => root_path},
    {:message => new_message_path},
    {:messages => messages_path},
  ]
end
