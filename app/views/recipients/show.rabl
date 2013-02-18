object @recipient
attributes *@content_attributes, :status, :created_at, :completed_at

node(:error_message, :unless => lambda { |r| r.error_message.nil? }) do |r|
  r.error_message
end
node(:errors, :unless => lambda { |r| r.valid? }) { |recipient| recipient.errors }
node('_links') { |r| View::RecipientLinks.new(r, self)._links }
