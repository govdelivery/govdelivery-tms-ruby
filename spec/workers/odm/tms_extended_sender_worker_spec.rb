require 'rails_helper'

if defined?(JRUBY_VERSION)
  java_import com.govdelivery.tms.tmsextended.ExtendedMessage

  describe Odm::TmsExtendedSenderWorker do
    let(:worker) { Odm::TmsExtendedSenderWorker.new }
    let(:odm_vendor) { create(:email_vendor, worker: 'LoopbackMessageWorker') }
    let(:account) { create(:account, :email_vendor => odm_vendor, name: 'name') }
    let(:recipients) do
      s = stub('recipients')
      s.stubs(:find_each).yields(EmailRecipient.new(:email => 'email@sink.govdelivery.com')).then.yields(EmailRecipient.new(:email => 'email2@sink.govdelivery.com'))
      s
    end
    let(:email_message) do
      msg = account.email_messages.new({'body' => '[[foo]] msg body',
                                        'subject'                => '[[foo]] msg subject',
                                        'from_name'              => 'Emailing Cat',
                                        'from_email'             => 'from@cat.com',
                                        'reply_to'               => 'reply@cat.com',
                                        'errors_to'              => 'errors@cat.com',
                                        'open_tracking_enabled'  => false,
                                        'click_tracking_enabled' => true,
                                        'macros'                 => {'macro1' => 'foo', 'macro2' => 'bar'}})
      msg.stubs('recipients').returns(recipients)
      msg
    end
    let(:extended_message) {
      mock('extended_message').tap do |m|
        m.expects(:subject=).with('##foo## msg subject')
        m.expects(:body=).with('##foo## msg body')
        m.expects(:from_name=).with('Emailing Cat')
        m.expects(:from_email=).with(email_message.from_email)
        m.expects(:errors_to_email=).with(email_message.errors_to)
        m.expects(:reply_to_email=).with(email_message.reply_to)
        m.expects(:email_column=).with('email')
        m.expects(:recipient_id_column=).with('recipient_id')
        m.expects(:record_designator=).with('email::recipient_id::macro1::macro2')
        m.expects(:track_clicks=).with(email_message.click_tracking_enabled?)
        m.expects(:track_opens=).with(email_message.open_tracking_enabled?)
        m.stubs(:to).returns([])
      end
    }
    let (:params) do
       p ={'message_id' => 11, 'account_id' => account.id}
       p
    end
    let (:odm_v2) { mock(' Odm::TmsExtendedSenderWorker::ODMv2') }
    let (:odm_service) { stub(' Odm::TmsExtendedSenderWorker::ODMv2_Service', :getTMSExtendedPort => odm_v2)}


    context 'a very happy send' do
      it 'should work' do
        email_message.expects(:sending!).with('dummy_id')
        ExtendedMessage.expects(:new).returns(extended_message)
        EmailMessage.expects(:find).with(11).returns(email_message)
        odm_v2.expects(:send_message).returns('dummy_id')
        Odm::TmsExtendedSenderWorker::TMSExtended_Service.expects(:new).returns(odm_service)

        worker.perform(params)
      end
    end

    context 'odm throws error' do

      it 'should catch Throwable and throw Ruby Exception' do
        ExtendedMessage.expects(:new).returns(extended_message)
        EmailMessage.expects(:find).with(11).returns(email_message)
        Odm::TmsExtendedSenderWorker::TMSExtended_Service.expects(:new).returns(odm_service)
        odm_v2.expects(:send_message).raises(Java::java::lang::Exception.new("hello Exception"))
  
        exception_check(worker, "hello Exception", params)
      end

      it 'should catch TMSFault and throw Ruby Exception' do
        ExtendedMessage.expects(:new).returns(extended_message)
        EmailMessage.expects(:find).with(11).returns(email_message)
        Odm::TmsExtendedSenderWorker::TMSExtended_Service.expects(:new).returns(odm_service)
        odm_v2.expects(:send_message).raises(Java::ComGovdeliveryTmsTmsextended::TMSFault.new("hello TMSFault", nil))

        exception_check(worker, "ODM Error: hello TMSFault", params)
      end
    end
  end
end
