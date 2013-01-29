class EmailMessage < ActiveRecord::Base
  include Message

  attr_accessible :subject, :body, :from_name

  validates :body, presence: true
  validates :subject, presence: true, length: {maximum: 400}

  delegate :from_email, :to => :account


  def sending_with_ack!(ack)
    self.ack=ack
    sending_without_ack!
  end
  alias_method_chain :sending!, :ack

end
