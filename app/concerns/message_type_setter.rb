module MessageTypeSetter
  ##
  # Set message type from params
  #
  attr_reader :message_type
  def message_type= str_or_kv
    case str_or_kv
      when String
        name_key = str_or_kv
      when Hash
        name_key, name = *str_or_kv.first
    end
    message_type = MessageType.where(account_id: account.id, name_key: name_key).first_or_create
    if !name.nil? && message_type.name != name
      message_type.update_attribute :name, name
    elsif message_type.name.nil?
      message_type.update_attribute :name, name_key
    end
    @message_type = message_type
  end
end
