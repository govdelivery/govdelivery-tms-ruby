module SmsReceiver

  module_function
  def respond_to_sms!(keyword, command_parameters)
    keyword.execute_commands(command_parameters)
    keyword.response_text
  end

end
