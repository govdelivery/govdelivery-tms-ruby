class Webhook < ActiveRecord::Base
  belongs_to :account
  attr_accessible :event_type, :url

  validates :event_type,
            presence:  true,
            inclusion: {in:      EmailRecipient.aasm.states.map(&:to_s) - ['new'],
                        message: '%{value} is not a valid event type'}
  validates :url, url: true

  def invoke(recipient)
    WebhookWorker.perform_async({url: url, job_key: job_key}.merge!(params: RecipientPresenter.new(recipient, account).to_webhook))
  end

  def job_key
    Addressable::URI.parse(url).host
  end
end
