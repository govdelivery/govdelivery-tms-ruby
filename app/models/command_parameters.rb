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
  include ActiveModel::Model
  include ActiveModel::Validations

  validate :validate_string_fields
  validate :validate_array_fields
  validate :validate_dcm_account

  # Some attributes in this collection may be persisted in the database as Command#params (marshalled
  # into YAML). Think hard about removing an attribute (maybe you want to do a data migration or
  # handle the missing method error).
  PARAMS = [
    :account_id,          # the xact account id corresponding to this command,
    :callback_url,        # a callback url for the external sms/voice service to call if needed
    :sms_body,            # the full body string of the incoming sms message
    :sms_tokens,          # an array of string tokens in the sms_body, sans keyword
    :from,                # phone number of user that sent us sms message
    :to,                  # phone number to which user sent message
    :username,            # username for HTTP BASIC auth during forward requests
    :encrypted_password,  # don't set this directly - setting :password sets this automatically
    :url,                 # the URL to send a forward request to
    :http_method,         # GET or POST - method of the forward request
    :from_param_name,     # the name of the phone number variable during forward commands
    :sms_body_param_name, # the name of the sms body variable during forward commands
    :strip_keyword,       # nil/"true" - remove the keyword from the sms body before forwarding. defaults to false.
    :dcm_account_codes,   # an array of codes, used for unsubscribing only
    :dcm_account_code,    # a single account code, used for subscribing to topics
    :dcm_topic_codes,     # array of topic codes (dcm_account_code must be set)
    :inbound_message_id,  # inbound SMS message id (for recording actions)
    :command_id           # initiating command id
  ]
  attr_accessor(*PARAMS)
  # attr_accessible *PARAMS

  # These are only required for validation, and are not (or shouldn't be) persisted or mass-assigned
  attr_accessor :command_type, :account

  # This is not persisted anywhere.  The getter/setter is used for bi-directional
  # encryption. If this property were in PARAMS, it would be serialized into the
  # database, which is exactly what we don't want.
  attr_encrypted :password, encode: true, key: 'blackleggery our rub discretionally how hitch bisontine that tree hemogastric he finishing transmissibility new spoon'
  # attr_accessible :password

  def merge!(params)
    params.to_hash.each do |attr, value|
      public_send("#{attr}=", value) if self.respond_to?("#{attr}=")
    end
  end

  # return a hash of values for this object's properties, but without any keys that
  # have nil values.  Please don't ever include password in this.  Only encrypted_password is
  # safe.
  def to_hash
    PARAMS.inject({}) do |hsh, p|
      # instance_variable_get is being used to avoid any mutations caused by
      # lazy getters (i.e. ones with default values)
      hsh.merge(p => instance_variable_get("@#{p}"))
    end.keep_if { |_k, v| !v.nil? }
  end

  def to_s
    "#<#{self.class} #{to_hash}>"
  end

  # This is what tells YAML which properties on this object
  # are to be included in serialization.
  def to_yaml_properties
    to_hash.keys.map { |p| "@#{p}" }
  end

  ##
  # The name of the sms body variable sent during a forward command
  def sms_body_param_name
    @sms_body_param_name ||= 'sms_body'
  end

  ##
  # The name of the phone number variable sent during a forward command
  def from_param_name
    @from_param_name ||= 'from'
  end

  private

  def validate_string_fields
    command_type.required_string_fields.each do |f|
      errors.add(f, :blank) if send(f).blank?
    end
  end

  def validate_array_fields
    command_type.required_array_fields.each do |f|
      errors.add(f, :blank) if send(f).blank?
      errors.add(f, 'must be an array') unless send(f).is_a?(Array)
    end
  end

  def valid_account_codes?(account, codes = dcm_account_codes)
    (codes || []).map(&:upcase).to_set.subset?(account.dcm_account_codes.to_set)
  end

  def valid_account_code?(account)
    valid_account_codes?(account, [dcm_account_code].compact)
  end

  def validate_dcm_account
    if command_type.required_string_fields.include?(:dcm_account_code) && !valid_account_code?(account)
      errors.add(:dcm_account_code, 'is not a valid code')
    elsif command_type.required_array_fields.include?(:dcm_account_codes) && !valid_account_codes?(account)
      errors.add(:dcm_account_codes, 'contain one or more invalid account codes')
    end
  end
end
