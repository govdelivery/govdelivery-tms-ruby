object @command_action
attributes :http_response_code, :http_content_type, :http_body, :created_at

node(:_links) do |m|
  {:self => inbound_sms_command_action_path(m.inbound_message_id, m.id),
   :inbound_sms_message => inbound_sms_path(m.inbound_message_id),
   :command => keyword_command_path(m.command.keyword_id, m.command_id)}
end