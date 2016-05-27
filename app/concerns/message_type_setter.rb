module MessageTypeSetter
  def self.included(base)
    base.class_eval do
      attr_accessor :message_type_label
      attr_writer :message_type_code
      attr_accessible :message_type_code, :message_type_label

      # message types are only auto-created when other things are created
      before_create :auto_create_message_type
    end
  end

  def auto_create_message_type
    if message_type_code && account
      message_type = MessageType.where(account_id: account.id, code: message_type_code).first_or_create
      if !message_type_label.nil? && message_type.label != message_type_label
        message_type.update_attribute :label, message_type_label
      elsif message_type.label.nil?
        message_type.update_attribute :label, message_type_code.titleize
      end
      self.message_type_id = message_type.id
    elsif message_type_label
      errors.add(:message_type_label, "Message type code is required.")
      false
    elsif self.class.name == 'EmailMessage' && email_template && account #if message_type is undefined for message, inherit from template
      self.message_type_id = email_template.try(:message_type).try(:id)
    end
  end

  def message_type_code
    @message_type_code ||= message_type.try(:code)
  end
end
