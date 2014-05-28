object @command_action
attributes :status, :content_type, :response_body, :created_at

node(:_links) do |m|
  result = {
    :self => inbound_sms_command_action_path(m.inbound_message_id, m.id),
    :inbound_sms_message => inbound_sms_path(m.inbound_message_id)
  }

  # stop and help commands don't have keywords and aren't accessible via the API
  unless m.command.keyword.special?
    result[:command] = keyword_command_path(m.command.keyword.id, m.command_id)
  end

  result
end
