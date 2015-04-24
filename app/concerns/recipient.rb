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
    %w(new sending)
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
      event :mark_sent, after: [:finalize, :invoke_webhooks] do
        transitions from: [:new, :sending, :inconclusive], to: :sent
      end

      event :mark_inconclusive, after: [:invoke_webhooks] do
        transitions from: [:new, :sending], to: :inconclusive
      end

      event :fail, after: [:invoke_webhooks] do
        transitions from: [:new, :inconclusive], to: :failed, after: :finalize
        transitions from: :sending, to: :sending, if: -> {!retries_exhausted?}, after: :record_attempt
        transitions from: :sending, to: :failed, if: :retries_exhausted?, after: :finalize
      end

      event :cancel, after: [:finalize, :invoke_webhooks] do
        transitions from: [:new, :sending, :inconclusive], to: :canceled
      end

      event :blacklist, after: :invoke_webhooks do
        transitions from: [:new, :sending], to: :blacklisted
      end

      event :bounce, after: [:invoke_webhooks] do
        transitions from: [:sending, :inconclusive, :canceled, :sent], to: :failed, after: :finalize
      end
    end

    attr_accessor :skip_message_validation

    belongs_to :message, class_name: name.gsub('Recipient', 'Message')
    belongs_to :vendor, class_name: name.gsub('Recipient', 'Vendor')

    scope :to_send, ->(_vendor_id) {where(nil)}
    scope :with_new_status, -> {where(status: 'new')}
    scope :incomplete, -> {where(status: Recipient.incomplete_statuses)}

    scope :timeout_expired, -> {sending.where('sent_at < ?', delivery_timeout.ago)}

    attr_accessible :message_id, :vendor_id, :vendor

    before_validation :truncate_values
    before_validation :set_vendor
    validates :error_message, length: {maximum: 512}
  end

  def truncate_values
    self.error_message = error_message[0..511] if error_message && error_message_changed? && error_message.to_s.length > 512
  end

  def sending!(ack, *_)
    mark_sending!(:sending, ack)
  end

  def sent!(ack, date_sent=nil, _=nil)
    date_sent ||= Time.now
    mark_sent!(:sent, ack, date_sent, nil)
  end

  def failed!(ack=nil, completed_at=nil, error_message=nil)
    fail!(:failed, ack, completed_at, error_message)
  end

  def canceled!(ack, *_)
    cancel!(:canceled, ack, nil, nil)
  end

  def ack!(ack=nil, *_)
    update_attribute(:ack, ack)
  end

  protected

  def retries_exhausted?
    true
  end

  def invoke_webhooks(*_)
    message.account.webhooks.where(event_type: status).each do |webhook|
      webhook.invoke(self)
    end
  end

  def finalize(ack, completed_at, error_message)
    self.ack           = ack if ack.present?
    self.completed_at  = completed_at || Time.now
    self.error_message = error_message
    self.save!
  end

  def acknowledge_sent(ack=nil, *_)
    self.ack     = ack
    self.sent_at = Time.now
  end

  def set_vendor
    self.vendor ||= message.try(:vendor)
  end
end
