object @recipient
attributes *@content_attributes, :status, :created_at, :completed_at

node(:error_message, :unless => lambda { |r| r.error_message.nil? }) do |r|
  r.error_message
end
node(:errors, :unless => lambda { |r| r.valid? }) { |recipient| recipient.errors }
node('_links') { |m| {:"#{m.message.class.name.underscore}" => url_for(:controller=>m.message.class.name.tableize, :action=>:show, :id=>m.message_id), :self=>url_for(:action=>:show, :id=>m.id) } }