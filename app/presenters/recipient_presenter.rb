class RecipientPresenter < SimpleDelegator
  attr_accessor :context, :account

  def initialize(recipient, account, context=Rails.application.routes.url_helpers)
    self.context = context
    self.account = account
    super(recipient)
  end

  def url
    context.send(:"#{message_type}_recipient_url", self.message_id, self)
  end

  def message_url
    context.send(:"#{message_type}_url", self.message_id)
  end

  def to_webhook
    params                 = {
      message_type:  self.message_type,
      status:        self.status,
      recipient_url: self.url,
      message_url:   self.message_url,
      sid:           self.account.sid
    }
    params[:error_message] = self.error_message if self.error_message
    params[:completed_at]  = self.completed_at if self.completed_at
    params
  end

  protected

  #polymorphic_path doesn't work here
  def message_type
    __getobj__.class.name.underscore.split('_').first #sms,voice,email
  end

end
