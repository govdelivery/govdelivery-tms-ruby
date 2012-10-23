object(@message)

node(:errors) { |message| message.errors.to_json } if @message.errors.any?