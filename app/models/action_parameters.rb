class ActionParameters
  PARAMS=[
    :params,     # params column on actions table
    :account_id, # 
    :sms_body,   # from the incoming sms message,
    :sms_tokens, # and array of string tokens in the sms_body
    :from        # phone number of user that sent us sms message
  ]
  attr_accessor *PARAMS

  def initialize(params={})
    assign!(params)
  end

  def assign!(params)
    params.each do |key, value|
      self.public_send("#{key}=", value)
    end
  end

  def to_hash
    PARAMS.inject({}){ |hsh, param| hsh.merge(param => self.send(param))}
  end

  def to_s
    to_hash.to_s
  end

end
