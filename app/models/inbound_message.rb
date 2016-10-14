class InboundMessage < ActiveRecord::Base
  belongs_to :vendor, inverse_of: :inbound_messages, class_name: 'SmsVendor'
  belongs_to :account # used for scoped reporting, can be blank
  belongs_to :keyword, inverse_of: :inbound_messages
  enum :command_status, [:no_action, :pending, :failure, :success, :ignored]

  attr_accessible :body, :from, :vendor, :to, :keyword, :keyword_response, :account_id

  validates :body, presence: true
  validates :from, presence: true
  validates :vendor, presence: true
  validates :vendor_sid, uniqueness: {allow_nil: true}
  alias_attribute :from, :caller_phone # 'caller_phone' is the database column, as 'from' is a reserved word in Oracle (who knew?)
  alias_attribute :to, :vendor_phone

  has_many :command_actions, dependent: :delete_all

  before_validation :set_response_status, on: :create
  before_create :see_if_this_should_be_ignored
  after_create :publish_event

  def update_status!(fail=false)
    if fail
      update_attribute :command_status, :failure
    else
      # failure stays
      if command_status != :failure && keyword.commands.count == command_actions.count
        # all have been completed, none have failed
        update_attribute :command_status, :success
      end
    end
  end

  #
  # This method will return false if one or more inbound messages precede this message
  # by a configurable time threshold and contain the same information.  This is
  # intended to prevent infinite loops caused by auto-response messages.
  #
  def actionable?
    compare_date = created_at || Time.now
    table = self.class.arel_table
    threshold = (compare_date - Xact::Application.config.auto_response_threshold.minutes).to_datetime
    self.class.where('created_at >= ?', threshold)
      .where(body: body)
      .where(caller_phone: caller_phone)
      .where(table[:id].not_eq(id)).count == 0
  end

  ##
  # I'm just doing this because Ben and Tyler are forcing me to
  # ~ Billy, 9/23/2013 (help me)
  # special case to handle auto-response
  def ignore!
    self.command_status = :ignored
    self.save! unless self.new_record?
  end

  def callback_id
    "#{self.class.name.underscore}-#{self.to_param}"
  end

  protected

  def see_if_this_should_be_ignored
    ignore! unless actionable?
  end

  def publish_event
    Analytics::PublisherWorker.perform_inline_or_async(
      channel: 'sms_channel',
      message: {
        uri:        'xact:sms:inbound',
        v:          '1',
        from_phone: from,
        to_phone:   to,
        body:       body,
        created_at: created_at
      }
    )
  end

  def set_response_status
    self.command_status = if !keyword.try(:commands).blank?
                            :pending
                          elsif keyword.try(:response_text)
                            :success
                          else
                            :no_action
                          end
  end
end
