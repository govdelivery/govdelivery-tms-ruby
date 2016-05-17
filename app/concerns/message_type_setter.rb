module MessageTypeSetter
  def self.included(base)
    base.class_eval do
      attr_accessible :message_type_code, :message_type_label
      attr_accessor :message_type_code, :message_type_label

      before_create :create_message_type
    end
  end

  #I don't know why I have to create these
  def message_type_code=code
    @message_type_code = code
  end

  def message_type_code
    @message_type_code
  end

  def message_type_label=label
    @message_type_label = label
  end

  def message_type_label
    @message_type_label
  end


  def create_message_type
    if message_type_code && account
      message_type = MessageType.where(account_id: account.id, code: message_type_code).first_or_create
      if !message_type_label.nil? && message_type.label != message_type_label
        message_type.update_attribute :label, message_type_label
      elsif message_type.label.nil?
        message_type.update_attribute :label, message_type_code.titleize
      end
      self.message_type_id = message_type.id
    elsif message_type_label
      raise ActiveRecord::ActiveRecordError, "Message type code is required."
      return false
    end
  end
end
