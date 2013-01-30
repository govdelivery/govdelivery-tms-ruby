class Account < ActiveRecord::Base
  attr_accessible :name, :sms_vendor, :email_vendor, :voice_vendor, :from_address

  has_many :users
  belongs_to :voice_vendor
  belongs_to :sms_vendor
  belongs_to :email_vendor
  has_many :sms_messages
  has_many :voice_messages
  has_many :email_messages
  has_one :from_address
  has_many :keywords
  belongs_to :stop_handler, :class_name => 'EventHandler'

  delegate :from_email, :reply_to_email, :bounce_email, :to => :from_address

  before_create :create_stop_handler!

  validates :name, presence: true, length: {maximum: 255}
  validates :from_address, presence: true, :if => '!email_vendor_id.blank?'

  def add_command!(params)
    unless stop_handler
      self.create_stop_handler!
      self.save!
    end
    stop_handler.commands.new(params).tap { |c| c.account = self }.save!
  end

  def feature_enabled?(feature)
    !!self.send("#{feature}_vendor")
  end

  def stop(params={})
    stop_handler.commands.each { |a| a.call(params) } if stop_handler
  end

end
