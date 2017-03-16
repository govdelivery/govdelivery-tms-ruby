class OneTimeSessionToken < ActiveRecord::Base
  belongs_to :user

  attr_accessible :user, :value

  validates :value, presence: true, uniqueness: true
  validates :user, presence: true

  before_validation :generate_value, on: :create

  def self.user_for(token_value)
    one_time_token = OneTimeSessionToken.find_by_value(token_value)
    one_time_token.destroy
    one_time_token.user
  end

  private

  def generate_value
    # Generate a token by looping and ensuring does not already exist.
    self.value = loop do
      # Devise.friendly_token is hard-coded to pass 15 to SecureRandom,
      # resulting in a token that is 20 chars in length.  We want
      # 32 chars, so we pass in 24 directly to SecureRandom
      token = SecureRandom.base64(24).tr('+/=lIO0', 'pqrsxyz')
      break token unless OneTimeSessionToken.where(value: token).count > 0
    end
  end

end