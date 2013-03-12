require 'spec_helper'
if defined?(JRUBY_VERSION)
  java_import com.govdelivery.tms.tmsextended.ExtendedMessage

  describe Odm::TmsExtendedSenderWorker do
    let(:odm_vendor) { create_email_vendor(:worker => 'LoopbackMessageWorker') }
    let(:account) { odm_vendor.accounts.create!(:name => 'name', :from_address=>create_from_address) }
    let(:recipients) do
      s = stub('recipients')
      s.stubs(:find_each).yields(EmailRecipient.new(:email => 'email@sink.govdelivery.com')).then.yields(EmailRecipient.new(:email => 'email2@sink.govdelivery.com'))
      s
    end
    let(:email_message) do
      msg = account.email_messages.new({'body' => '[[foo]] msg body',
                                        'subject' => '[[foo]] msg subject',
                                        'from_name' => 'Emailing Cat',
                                        'open_tracking_enabled' => false,
                                        'click_tracking_enabled' => true,
                                        'macros' => {'macro1' => 'foo', 'macro2' => 'bar'}})
      msg.expects(:sending!).with('dummy_id')
      msg.stubs('recipients').returns(recipients)
      msg
    end
    let(:extended_message) {
      mock('extended_message').tap do |m|
        m.expects(:subject=).with('##foo## msg subject')
        m.expects(:body=).with('##foo## msg body')
        m.expects(:from_name=).with('Emailing Cat')
        m.expects(:from_email=).with(account.from_email)
        m.expects(:errors_to_email=).with(account.bounce_email)
        m.expects(:reply_to_email=).with(account.reply_to_email)
        m.expects(:email_column=).with('email')
        m.expects(:recipient_id_column=).with('recipient_id')
        m.expects(:record_designator=).with('email::recipient_id::macro1::macro2')
        m.expects(:track_clicks=).with(email_message.click_tracking_enabled?)
        m.expects(:track_opens=).with(email_message.open_tracking_enabled?)
        m.stubs(:to).returns([])
      end
    }


    context 'a very happy send' do
      let(:worker) { Odm::TmsExtendedSenderWorker.new }

      it 'should work' do
        ExtendedMessage.expects(:new).returns(extended_message)
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