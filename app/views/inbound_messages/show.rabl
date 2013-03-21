object @message
attributes :from, :to, :body, :command_status, :created_at

node('_links') { |m|
  hsh = {:self => url_for(:controller => 'inbound_messages', :action => 'show', :id => m.id)}
  hsh[:command_actions] = inbound_sms_command_actions_path(m) if m.command_actions.any?
  hsh
}
