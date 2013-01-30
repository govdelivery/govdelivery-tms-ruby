require 'spec_helper'
if defined?(JRUBY_VERSION)

  describe Odm::TmsExtendedSenderWorker do
    let(:odm_vendor) { create_email_vendor(:worker => 'LoopbackMessageWorker') }
    let(:account) { odm_vendor.accounts.create!(:name => 'name', :from_address=>create_from_address) }
    let(:recipients) do
      s = stub('recipients')
      s.stubs(:find_each).yields(EmailRecipient.new(:email => 'email@sink.govdelivery.com')).then.yields(EmailRecipient.new(:email => 'email2@sink.govdelivery.com'))
      s
    end
    let(:email_message) do
      msg = account.email_messages.new({'body' => 'msg body',
                                        'subject' => 'msg subject',
                                        'from_name' => 'Emailing Cat'})
      msg.expects(:sending!).with('dummy_id')
      msg.stubs('recipients').returns(recipients)
      msg
    end


    context 'a very happy send' do
      let(:worker) { Odm::TmsExtendedSenderWorker.new }

      it 'should work' do

        EmailMessage.expects(:find).with(11).returns(email_message)
        params = {'message_id' => 11,
                  'account_id' => account.id}
        odm_v2 = mock(' Odm::TmsExtendedSenderWorker::ODMv2')
        odm_v2.expects(:send_message).returns('dummy_id')

        odm_service = stub(' Odm::TmsExtendedSenderWorker::ODMv2_Service', :getTMSExtendedPort => odm_v2)
        Odm::TmsExtendedSenderWorker::TMSExtended_Service.expects(:new).returns(odm_service)

        worker.perform(params)
      end
    end

  end
end