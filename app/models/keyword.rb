class Keyword < ActiveRecord::Base
  attr_accessible :account, :vendor

  RESERVED_KEYWORDS = %w(stop quit help)

  has_many :actions

  belongs_to :vendor
  belongs_to :account
  belongs_to :event_handler
  validates_presence_of :name, :account, :vendor
  validates_length_of :name, :maximum => 160
  validates_uniqueness_of :name, :scope => "account_id"
  validate :name_not_reserved

  def name=(n)
    write_attribute(:name, sanitize_name(n))
  end

  def add_action!(params)
    unless event_handler
      self.create_event_handler!
      self.save!
    end
    event_handler.actions.create!({:account => self.account}.merge(params))
  end

  def execute_actions(params={})
    event_handler.actions.each{|a| a.call(params)} if event_handler
  end

  private

  def sanitize_name(n)
    n.try(:downcase).try(:strip)
  end

  def name_not_reserved
    if RESERVED_KEYWORDS.any? { |kw| /^(#{kw} |#{kw}$)/ =~ self.name }
      errors.add(:name, "Illegal keyword name #{self.name}")
    end
  end
end
