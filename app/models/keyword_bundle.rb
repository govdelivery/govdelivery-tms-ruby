## 
# Represents a collection of keywords that 
# are possible matches for an sms body, 
# based on the state of the vendor and the enclosed
# accounts' prefixes. 
#
class KeywordBundle
  attr_accessor :vendor, :sms_body
  delegate :shared?, :keywords, :sms_prefixes, :to => :vendor

  def initialize(vendor, sms_body)
    self.vendor   = vendor
    self.sms_body = sms_body
  end

  ##
  # Return all of the account's keywords that match this sms_body's prefix if
  # this is a shared vendor.  If no match is found, return an empty array.
  # If this is not a shared vendor, return all keywords.
  #
  def prefixed_keywords
    shared? ? account_keywords : keywords
  end

  ##
  # If this is a shared vendor, remove the prefix from the input string
  # if a match is found in the database.
  # 
  def body_without_prefix
    shared? ? account_sms_body : sms_body
  end

  def stop_action
    ->(params) do
      vendor.stop!(params)
    end
  end

  def stop_text
    vendor.stop_text
  end

  def help_text
    vendor.help_text
  end

  private

  ##
  # strip the sms_prefix off of an sms message and return the stripped message
  #
  def account_sms_body
    if sms_prefixes.where("lower(prefix) = ?", first_word(sms_body)).count > 0
      sms_body.gsub(/^\s*#{first_word(sms_body)}\s*/i, '')
    else
      sms_body
    end
  end

  #
  # return all of the keywords for an account with a prefix that matches
  # this sms body
  #
  def account_keywords
    if prefix = sms_prefixes.where("lower(prefix) = ?", first_word(sms_body)).first
      prefix.account.keywords
    else
      []
    end
  end

  def first_word(sms_body)
    (sms_body.strip.split(/\s/)[0] || '').downcase
  end

end