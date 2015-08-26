class EmailRecipient < ActiveRecord::Base
  include Recipient
  include Personalized

  self.delivery_timeout = Rails.configuration.email_delivery_timeout

  attr_accessible :email
  validates :message, presence: {unless: :skip_message_validation}
  validates :email, presence: true, length: {maximum: 256}, email: true

  ##
  # The conditions on these scopes add message_id, which is at the front of the index on those tables
  # (and will become the partition key in the near future). Removing this condition will make
  # these relations perform very poorly.
  #
  has_many :email_recipient_clicks, ->(record) {where('email_recipient_clicks.email_message_id = ?', record.message_id)}
  has_many :email_recipient_opens, ->(record) {where('email_recipient_opens.email_message_id = ?', record.message_id)}

  scope :status_columns, -> {select(column_names - ['macros'])}

  def self.from_x_tms_recipent(header)
    xtr = GovDelivery::Crypt::XTmsRecipient.decrypt(header)
    status_columns.where(email: xtr.email).find(xtr.recipient_id)
  end

  ##
  # Convert this recipient into a record string for sending to ODM.
  #
  # Macros for this recipient that are not present in the default hash (at the message level)
  # will be discarded - otherwise, they would invalidate the
  # record designator, which is build at the message level
  #
  # @param defaults [Hash] the default macros - i.e. self.message.macros
  # @return [String]
  #
  def to_odm(defaults={})
    record = [email, id, x_tms_recipient].join('::')
    defaults.merge(macros || {}).tap do |hsh|
      unless hsh.empty?
        hsh.keys.sort.each do |k|
          record << "::#{hsh[k]}" if defaults.key?(k)
        end
      end
    end unless defaults.nil?
    record
  end

  def arf!(_, _, error_message)
    update_attribute(:error_message, error_message).tap do
      Analytics::PublisherWorker.perform_async(channel: 'email_channel', message: {uri: "arf", v: '1', account_sid: message.account.sid, message_id: message.id, recipient_id: id})
    end
  end

  def hard_bounce!(*args)
    bounce!(:failed, *args).tap do
      Analytics::PublisherWorker.perform_async(channel: 'email_channel', message: {uri: "bounced", v: '1', account_sid: message.account.sid, message_id: message.id, recipient_id: id})
    end
  end

  # soft and hard bounces are the same for our purposes in that the message failed
  alias_method :soft_bounce!, :hard_bounce!
  alias_method :mail_block!, :hard_bounce!

  # Record a click on a URL for this recipient / email combination
  def clicked!(url, date)
    email_recipient_clicks.build.tap do |erc|
      erc.clicked_at = date
      erc.url = url
      erc.email_message = message
      erc.email = email
      erc.save!
      Analytics::PublisherWorker.perform_async(channel: 'email_channel', message: {uri: "clicked", v: '1', account_sid: message.account.sid, message_id: message.id, recipient_id: id, url: url})
    end
  end

  # Record an open on this email / recipient combination
  def opened!(ip, date)
    email_recipient_opens.build.tap do |ero|
      ero.opened_at = date
      ero.event_ip = ip
      ero.email_message = message
      ero.email = email
      ero.save!
      Analytics::PublisherWorker.perform_async(channel: 'email_channel', message: {uri: 'opened', v: '1', account_sid: message.account.sid, message_id: message.id, recipient_id: id})
    end
  end

  def sent!(ack, date_sent=nil, _=nil)
    super.tap do
      Analytics::PublisherWorker.perform_async(channel: 'email_channel', message: {uri: 'sent', v: '1', account_sid: message.account.sid, message_id: message.id, recipient_id: id})
    end
  end

  def failed!(ack=nil, completed_at=nil, error_message=nil)
    super.tap do
      Analytics::PublisherWorker.perform_async(
        channel: 'email_channel',
        message: {
          uri:           'failed',
          v:             '1',
          account_sid:   message.account.sid,
          message_id:    message.id,
          recipient_id:  id,
          error_message: error_message})
    end
  end

  def canceled!(ack, *_)
    super.tap do
      Analytics::PublisherWorker.perform_async(channel: 'email_channel', message: {uri: "canceled", v: '1', account_sid: message.account.sid, message_id: message.id, recipient_id: id})
    end
  end

  def x_tms_recipient
    GovDelivery::Crypt::XTmsRecipient.encrypt(email, id)
  end
end
