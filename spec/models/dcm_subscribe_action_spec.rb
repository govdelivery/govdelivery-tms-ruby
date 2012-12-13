require File.expand_path('../../../app/models/phone_number', __FILE__)
require File.expand_path('../../../app/models/dcm_subscribe_action', __FILE__)
require File.expand_path('../../little_spec_helper', __FILE__)

describe DcmSubscribeAction do
  let(:client) { mock('dcm_client') }
  let(:fake_phone_number_constructor) { lambda {|pn| stub(:dcm => '1+4443332222') } }
  subject { DcmSubscribeAction.new(client) }

  it 'should call wireless_subscribe on the DCM Client' do
    client.expects(:wireless_subscribe).with('1+4443332222', 'ACCOUNT_CODE', ['TOPIC_CODE', 'TOPIC_2'])

    subject.call('+14443332222', 'ACCOUNT_CODE:TOPIC_CODE,TOPIC_2', [], fake_phone_number_constructor)
  end

  context "with subscribe args" do
    it 'should call email_subscribe on the DCM Client when email is valid' do
      client.expects(:email_subscribe).with('donkey@govdelivery.com', 'ACCOUNT_CODE', ['TOPIC_CODE', 'TOPIC_2'])

      subject.call('+14443332222', 'ACCOUNT_CODE:TOPIC_CODE,TOPIC_2', ['donkey@govdelivery.com'], fake_phone_number_constructor)
    end
    it 'should call email_subscribe on the DCM Client when email is invalid' do
      client.expects(:wireless_subscribe).with('1+4443332222', 'ACCOUNT_CODE', ['TOPIC_CODE', 'TOPIC_2'])

      subject.call('+14443332222', 'ACCOUNT_CODE:TOPIC_CODE,TOPIC_2', ['donkeygovdelivery.com'], fake_phone_number_constructor)
    end
  end

  it 'does not rescue exceptions' do
    error = Exception.new('error!!!')
    client.expects(:wireless_subscribe).raises(error)

    begin
      subject.call('+14443332222', 'ACCOUNT_CODE:TOPIC_CODE,TOPIC_2', [], fake_phone_number_constructor)
    rescue Exception => e
      e.should == error
    end
  end

end
