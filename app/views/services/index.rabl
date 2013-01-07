object false

node(:'_links') do
  [
    {:self => root_path},
    {:messages => messages_path},
    {:emails => emails_path},
    {:inbound_messages => inbound_messages_path},
  ]
end
