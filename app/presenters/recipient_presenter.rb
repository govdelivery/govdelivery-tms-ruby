class RecipientPresenter < SimpleDelegator
  attr_accessor :context, :account

  def initialize(recipient, account, context = Rails.application.routes.url_helpers)
    self.context = context
    self.account = account
    super(recipient)
  end

  def url
    context.send(:"#{message_type}_recipient_url", message_id, self)
  end

  def message_url
    context.send(:"#{message_type}_url", message_id)
  end

  def to_webhook
    params                 = {
      message_type:  message_type,
      status:        status,
      recipient_url: url,
      message_url:   message_url,
      sid:           account.sid
    }
    params[:error_message] = error_message if error_message
    params[:completed_at]  = completed_at if completed_at
    params
  end

  protected

  # polymorphic_path doesn't work here
  def message_type
    __getobj__.class.name.underscore.split('_').first # sms,voice,email
  end
end
