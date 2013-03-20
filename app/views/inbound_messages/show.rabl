object @message
attributes :from, :to, :body, :created_at

node('_links') { |m|
  {:self => url_for(:controller => 'inbound_messages', :action => 'show', :id => m.id),
   :command_actions => inbound_sms_command_actions_path(m)
  }
}
