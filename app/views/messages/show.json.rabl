object @message
attributes @content_attribute, :completed_at, :created_at

def message_recipients_path(m)
    return nil unless m.id
    opts = {:controller=>'recipients'}
    if m.is_a?(VoiceMessage)
      opts[:voice_id] = m.id
    elsif m.is_a?(SmsMessage)
      opts[:sms_id] = m.id
    end
    url_for(opts)
end

if root_object
  unless root_object.errors.empty?
    node(:errors) { |message| message.errors }
  end

  node(:_links) do |m|
    {:self => m.persisted? ? url_for(:controller=>controller_name, :action=>'show', :id=>m.id) : url_for(:controller=>controller_name),
     :recipients => message_recipients_path(m)}
  end
end
