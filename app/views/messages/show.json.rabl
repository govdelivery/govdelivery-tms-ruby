object @message
attributes @content_attribute, :completed_at, :created_at
if @message
  unless @message.errors.empty?
    node(:errors) { |message| message.errors }
  end

  node(:_links) do |m|
    {:self => m.persisted? ? send("#{controller_name.singularize}_path",m) : send("#{controller_name}_path"), :recipients => message_recipients_path(m)}
  end
end