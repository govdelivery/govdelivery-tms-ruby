#
# Before saving, recipient tries to properly format the 
# provided phone attribute into the formatted_phone attribute. 
#
# A recipient without a formatted_phone is one that we 
# cannot possibly forward on to the third-party provider. 
#
module Recipient
  extend ActiveSupport::Concern

  included do
    include AASM

    aasm column: 'status' do
      state :new, initial: true
      state :sending
      state :inconclusive
      state :blacklisted
      state :canceled
      state :sent
      state :failed

      event :mark_sending do
        transitions from: :new, to: :sending, on_transition: Proc.new { |obj, *args| obj.ack = args[0] }
      end

      event :mark_sent do
        transitions from: [:new, :sending], to: :sent, on_transition: :finalize
      end

      event :fail do
        transitions from: [:new, :sending, :inconclusive], to: :failed, on_transition: :finalize
      end

      event :cancel do
        transitions from: [:new, :sending], to: :canceled, on_transition: :finalize
      end

      event :blacklist do
        transitions from: [:new, :sending], to: :blacklisted
      end
    end

    attr_accessor :skip_message_validation

    belongs_to :message, :class_name => self.name.gsub('Recipient', 'Message')
    belongs_to :vendor, :class_name => self.name.gsub('Recipient', 'Vendor')

    scope :to_send, ->(vendor_id) { self }
    scope :with_new_status, -> { where(status: RecipientStatus::NEW) }
    scope :incomplete, -> { where(status: RecipientStatus::INCOMPLETE_STATUSES) }
    scope :sending, -> { where(status: RecipientStatus::SENDING) }
    scope :most_recently_sent, -> { order('sent_at DESC').limit(1) }

    attr_accessible :message_id, :vendor_id, :vendor

    before_validation :truncate_values
    before_validation :set_vendor
    validates :error_message, length: {maximum: 512}
  end

  def truncate_values
    self.error_message = self.error_message[0..511] if error_message && error_message_changed? && error_message.to_s.length > 512
  end

  def sending!(ack, *args)
    mark_sending!(:sending, ack)
  end

  def sent!(ack, date_sent=nil)
    mark_sent!(:sent, ack, date_sent)
  end

  def failed!(ack=nil, error_message=nil, completed_at=nil)
    fail!(:failed, ack, completed_at, error_message)
  end

  def canceled!(ack, *args)
    cancel!(:canceled, ack)
  end

  def ack!(ack=nil)
    self.ack = ack
    save!
  end

  protected

  def finalize(*args)
    self.ack           ||= args[0]
    self.completed_at  = args[1] || Time.now
    self.error_message = args[2]
  end

  def set_vendor
    self.vendor ||= self.message.try(:vendor)
  end

end
