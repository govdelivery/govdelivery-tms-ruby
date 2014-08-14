class Webhook < ActiveRecord::Base
  belongs_to :account
  attr_accessible :event_type, :url

  validates :event_type,
            presence:  true,
            inclusion: {in:      EmailRecipient.aasm.states.map(&:to_s) - ['new'],
                        message: "%{value} is not a valid event type"}

  def invoke(recipient)
    WebhookWorker.perform_async({url: self.url}.merge!(params: RecipientPresenter.new(recipient).webhook_params))
  end


end
