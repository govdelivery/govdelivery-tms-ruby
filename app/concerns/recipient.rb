#
# Before saving, recipient tries to properly format the
# provided phone attribute into the formatted_phone attribute.
#
# A recipient without a formatted_phone is one that we
# cannot possibly forward on to the third-party provider.
#
module Recipient
  extend ActiveSupport::Concern
  class ShouldRetry < StandardError

  end

  def incomplete_statuses
    ['new', 'sending']
  end

  module_function :incomplete_statuses

  included do
    include AASM
    cattr_accessor :delivery_timeout

    aasm column: 'status' do
      state :new, initial: true
      state :sending
      state :inconclusive
      state :blacklisted
      state :canceled
      state :sent
      state :failed

      event :mark_sending, after: :invoke_webhooks do
        transitions from: [:new, :sending], to: :sending, after: :acknowledge_sent
      end

      # ack, sent_at, error_message, call_status (for voice)
      event :mark_sent, after: :invoke_webhooks do
        transitions from: [:new, :sending, :inconclusive], to: :sent, after: :finalize
      end

      event :mark_inconclusive, after: :invoke_webhooks do
        transitions from: [:new, :sending], to: :inconclusive, after: :finalize
      end

      event :fail, after: :invoke_webhooks do
        transitions from: [:new, :sending, :inconclusive], to: :failed, after: :finalize
      end

      event :cancel, after: :invoke_webhooks do
        transitions from: [:new, :sending], to: :canceled, after: :finalize
      end

      event :blacklist, after: :invoke_webhooks do
        transitions from: [:new, :sending], to: :blacklisted
      end

      event :mark_attempt do
        transitions from: [:new, :sending], to: :failed, if: :retries_exhausted?, after: :finalize
      end
    end

    attr_accessor :skip_message_validation

    belongs_to :message, class_name: self.name.gsub('Recipient', 'Message')
    belongs_to :vendor, class_name: self.name.gsub('Recipient', 'Vendor')

    scope :to_send, ->(vendor_id) { where(nil) }
    scope :with_new_status, -> { where(status: 'new') }
    scope :incomplete, -> { where(status: Recipient.incomplete_statuses) }

    scope :timeout_expired, -> { sending.where("sent_at < ?", self.delivery_timeout.ago) }

    attr_accessible :message_id, :vendor_id, :vendor

    before_validation :truncate_values
    before_validation :set_vendor
    validates :error_message, length: {maximum: 512}
  end

  def truncate_values
    self.error_message = self.error_message[0..511] if error_message && error_message_changed? && error_message.to_s.length > 512
  end

  def sending!(ack, *_)
    mark_sending!(:sending, ack)
  end

  def sent!(ack, date_sent=nil, _=nil)
    date_sent ||= Time.now
    mark_sent!(:sent, ack, date_sent, nil, nil)
  end

  def failed!(ack=nil, completed_at=nil, error_message=nil)
    fail!(:failed, ack, completed_at, error_message, nil)
  end

  def canceled!(ack, *_)
    cancel!(:canceled, ack, nil, nil, nil)
  end

  def ack!(ack=nil, *_)
    update_attribute(:ack, ack)
  end

  protected
  def mark_attempt(*_)
    # noop
  end

  def invoke_webhooks(*_)
    message.account.webhooks.where(event_type: self.status).each do |webhook|
      webhook.invoke(self)
    end
  end

  def finalize(ack, completed_at, error_message, _)
    self.ack           = ack if ack.present?
    self.completed_at  = completed_at || Time.now
    self.error_message = error_message
  end

  def acknowledge_sent(*args)
    self.ack     = args[0]
    self.sent_at = Time.now
  end

  def set_vendor
    self.vendor ||= self.message.try(:vendor)
  end
end
