class InboundMessage < ActiveRecord::Base
  belongs_to :vendor, inverse_of: :inbound_messages, class_name: 'SmsVendor'
  belongs_to :keyword, inverse_of: :inbound_messages
  enum :command_status, [:no_action, :pending, :failure, :success]

  attr_accessible :body, :from, :vendor, :to, :keyword, :keyword_response
  validates_presence_of :body, :from, :vendor
  alias_attribute :from, :caller_phone # 'caller_phone' is the database column, as 'from' is a reserved word in Oracle (who knew?)
  alias_attribute :to, :vendor_phone

  has_many :command_actions, dependent: :delete_all

  before_validation :set_response_status, :on => :create

  def check_status!
    return unless keyword
    self.command_status = case keyword.commands.count
                            when command_actions.successes.count
                              :success
                            when command_actions.count
                              :failure
                            else
                              :pending
                          end
    self.save!
  end

  protected

  def set_response_status
    self.command_status = :no_action
    if keyword
      if !keyword.response_text.blank?
        self.keyword_response = keyword.response_text
        self.command_status = :success
      end
      if keyword.commands.any?
        self.command_status = :pending
      end
    elsif !keyword_response.blank?
      self.command_status = :success
    end
    true
  end
end


