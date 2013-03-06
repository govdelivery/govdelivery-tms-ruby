#
# This class ends up serialized in YAML in 
# the commands table.  It mixes variables from different contexts (commands table, 
# 
# This class is able to cleanly cross the boundary between web server and background
# processing without issues (because it can be reconstituted from a plain old Hash).
#
# To convert to hash: 
#   instance.to_hash 
# To convert from hash: 
#   CommandParameters.new({...})
#
class CommandParameters
  include MassAssignment
  include ActiveModel::Validations

  validate :validate_fields
  validate :validate_array_fields
  validate :validate_dcm_account

  # Some attributes in this collection may be persisted in the database as Command#params (marshalled
  # into YAML). Think hard about removing an attribute (maybe you want to do a data migration or 
  # handle the missing method error). 
  PARAMS=[
    :account_id,        # the xact account id corresponding to this command,
    :callback_url,      # a callback url for the external sms/voice service to call if needed
    :sms_body,          # the full body string of the incoming sms message
    :sms_tokens,        # an array of string tokens in the sms_body, sans keyword
    :from,              # phone number of user that sent us sms message
    :to,                # phone number to which user sent message
    :username,
    :encrypted_password,
    :url,
    :http_method,
    :dcm_account_codes, # an array of codes, used for unsubscribing only
    :dcm_account_code,  # a single account code, used for subscribing to topics
    :dcm_topic_codes    # array of topic codes (dcm_account_code must be set)
  ]
  attr_accessor *PARAMS
  attr_accessible *PARAMS

  # These are only required for validation, and are not (or shouldn't be) persisted or mass-assigned
  attr_accessor :command_type, :account  

  # This is not persisted anywhere.  The getter/setter is used for bi-directional
  # encryption. If this property were in PARAMS, it would be serialized into the 
  # database, which is exactly what we don't want. 
  attr_encrypted :password, :encode => true, :key => "blackleggery our rub discretionally how hitch bisontine that tree hemogastric he finishing transmissibility new spoon"
  attr_accessible :password

  def merge!(params)
    assign!(params.to_hash)
  end

  # return a hash of values for this object's properties, but without any keys that
  # have nil values.  Please don't ever include password in this.  Only encrypted_password is
  # safe.  
  def to_hash
    PARAMS.inject({}) {|hsh, p| hsh.merge(p => self.send(p))}.keep_if{|k,v| !v.nil?}
  end

  def to_s
    "#<#{self.class} #{self.to_hash}>"
  end

  # This is what tells YAML which properties on this object
  # are to be included in serialization.  
  def to_yaml_properties
    to_hash.keys.map{|p| "@#{p}"}
  end

  private

  def validate_fields
    command_type.fields.each do |f|
      errors.add(f, :blank) if self.send(f).blank?
    end
  end

  def validate_array_fields
    command_type.array_fields.each do |f|
      errors.add(f, :blank) if self.send(f).blank?
      errors.add(f, "must be an array") unless self.send(f).is_a?(Array)
    end
  end

  def valid_account_codes?(account, codes=dcm_account_codes)
    (codes || []).map(&:upcase).to_set.subset?(account.dcm_account_codes.to_set)
  end

  def valid_account_code?(account)
    valid_account_codes?(account, [self.dcm_account_code].compact)
  end

  def validate_dcm_account
    if command_type.fields.include?(:dcm_account_code) && !valid_account_code?(account)
      errors.add(:dcm_account_code, "is not a valid code")
    elsif command_type.array_fields.include?(:dcm_account_codes) && !valid_account_codes?(account)
      errors.add(:dcm_account_codes, "contain one or more invalid account codes")
    end
  end
end
