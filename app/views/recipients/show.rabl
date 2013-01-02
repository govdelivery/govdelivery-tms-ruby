object @recipient
attributes :formatted_phone, :phone, :status, :created_at, :sent_at, :completed_at
node(:error_message, :unless => lambda { |r| r.error_message.nil? }) do |r|
  r.error_message
end
node(:errors, :unless => lambda { |r| r.valid? }) { |recipient| recipient.errors }
node('_links') { |m| {:message => message_path(m.message_id), :self => message_recipient_path(m.message_id, m)} }