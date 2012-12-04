require_relative '../../app/models/dcm_subscribe_action'
require_relative '../little_spec_helper'

describe DcmSubscribeAction do
  let(:client) { mock('dcm_client') }
  let(:fake_phone_number_constructor) { lambda {|pn| stub(:dcm => '1+4443332222') } }
  subject { DcmSubscribeAction.new(client) }

  it 'should call wireless_subscribe on the DCM Client' do
    client.expects(:wireless_subscribe).with('1+4443332222', 'ACCOUNT_CODE', ['TOPIC_CODE', 'TOPIC_2'])

    subject.call('+14443332222', 'ACCOUNT_CODE:TOPIC_CODE,TOPIC_2', fake_phone_number_constructor)
  end

  it 'does not rescue exceptions' do
    error = Exception.new('error!!!')
    client.expects(:wireless_subscribe).raises(error)

    begin
      subject.call('+14443332222', 'ACCOUNT_CODE:TOPIC_CODE,TOPIC_2', fake_phone_number_constructor)
    rescue Exception => e
      e.should == error
    end
  end

end
