object false

node(:'_links') do
  [
    {:self => root_path},
    {:sms => sms_index_path},
    {:voice_messages => voice_index_path},
    {:emails => email_index_path},
    {:inbound_sms => inbound_sms_index_path},
    {:command_types => command_types_path},
    {:keywords => keywords_path}
  ]
end
