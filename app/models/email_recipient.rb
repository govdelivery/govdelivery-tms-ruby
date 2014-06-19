class EmailRecipient < ActiveRecord::Base
  include Recipient
  include Personalized

  attr_accessible :email
  validates_presence_of :message, :unless => :skip_message_validation
  validates :email, :presence => true, length: {maximum: 256}, :email => true

  ##
  # The conditions on these scopes add message_id, which is at the front of the index on those tables
  # (and will become the partition key in the near future). Removing this condition will make
  # these relations perform very poorly.
  #
  has_many :email_recipient_clicks, :conditions => proc{"email_recipient_clicks.email_message_id = #{self.message_id}"}
  has_many :email_recipient_opens, :conditions => proc{"email_recipient_opens.email_message_id = #{self.message_id}"}

  scope :failed, -> { where( status: RecipientStatus::FAILED ) }
  scope :sent,   -> { where( status: RecipientStatus::SENT ) }

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
    record = "#{self.email}::#{self.id}"
    defaults.merge(self.macros).tap do |hsh|
      unless hsh.empty?
        hsh.keys.sort.each do |k|
          record << "::#{hsh[k]}" if defaults.has_key?(k)
        end
      end
    end
    record
  end

  # Record a click on a URL for this recipient / email combination
  def clicked!(url, date)
    email_recipient_clicks.build.tap do |erc|
      erc.clicked_at = date
      erc.url = url
      erc.email_message = message
      erc.email = email
      erc.save!
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
    end
  end
end
