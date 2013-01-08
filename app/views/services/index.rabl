object false

node(:'_links') do
  [
    {:self => root_path},
    {:sms_messages => sms_messages_path},
    {:voice_messages => voice_messages_path},
    {:emails => emails_path},
    {:inbound_messages => inbound_messages_path},
    {:action_types => action_types_path}
  ]
end
