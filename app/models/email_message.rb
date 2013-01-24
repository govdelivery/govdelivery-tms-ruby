class EmailMessage < ActiveRecord::Base
  include Message

  attr_accessible :subject, :body, :from_name

  validates :body, presence: true
  validates :subject, presence: true, length: {maximum: 400}
end
