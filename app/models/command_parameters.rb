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

  # Some attributes in this collection may be persisted in the database as Command#params (marshalled
  # into YAML). Think hard about removing an attribute (maybe you want to do a data migration or 
  # handle the missing method error). 
  PARAMS=[
    :account_id,        # the tsms account id corresponding to this command,
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

  # This is not persisted anywhere.  The getter/setter is used for bi-directional
  # encryption. If this property were in PARAMS, it would be serialized into the 
  # database, which is exactly what we don't want. 
  attr_encrypted :password, :encode => true, :key => "blackleggery our rub discretionally how hitch bisontine that tree hemogastric he finishing transmissibility new spoon"

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
end
