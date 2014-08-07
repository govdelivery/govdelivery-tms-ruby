require 'rails_helper'

describe SmsReceiver, '#respond_to_sms!' do


  context 'given a keyword and command_parameters' do
    it 'should return help_text from a help keyword' do
      help_text = 'faster than a speeding bullet'
      keyword = create(:account_with_sms).help_keyword
      command_parameters = CommandParameters.new
      response = SmsReceiver.respond_to_sms! keyword, command_parameters
      response.should eql( keyword.response_text )
    end
  end
end
