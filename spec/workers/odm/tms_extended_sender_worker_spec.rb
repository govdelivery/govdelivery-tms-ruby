require 'rails_helper'

if defined?(JRUBY_VERSION)
  java_import com.govdelivery.tms.tmsextended.ExtendedMessage

  describe Odm::TmsExtendedSenderWorker do
    let(:worker) {Odm::TmsExtendedSenderWorker.new}
    let(:odm_vendor) {create(:email_vendor, worker: 'LoopbackMessageWorker')}
    let(:account) {create(:account, email_vendor: odm_vendor, name: 'name')}
    let(:recipients) { email_message.recipients }
      

    let(:email_message) do
      create(:email_message, 
              account:                account, 
              body:                   '[[foo]] msg body',
              subject:                '[[foo]] msg subject',
              from_name:              'Emailing Cat',
              reply_to:               'reply@cat.com',
              errors_to:              'errors@cat.com',
              open_tracking_enabled:  false,
              click_tracking_enabled: true,
              macros:                 {'macro1' => 'foo', 'macro2' => 'bar'}).tap do |m|
        m.create_recipients([
          {email: 'email1@sink.govdelivery.com'},
          {email: 'email2@sink.govdelivery.com'}
        ])
        m.ready!
      end
    end

    let(:extended_message) do
      mock('extended_message').tap do |m|
        m.expects(:subject=).with('##foo## msg subject')
        m.expects(:body=).with('##foo## msg body')
        m.expects(:from_name=).with(email_message.from_name)
        m.expects(:from_email=).with(email_message.from_email)
        m.expects(:headers).returns(mock('getHeaders()', '<<' => true))
        m.expects(:errors_to_email=).with(email_message.errors_to)
        m.expects(:reply_to_email=).with(email_message.reply_to)
        m.expects(:email_column=).with('email')
        m.expects(:recipient_id_column=).with('recipient_id')
        m.expects(:record_designator=).with('email::recipient_id::x_tms_recipient::macro1::macro2')
        m.expects(:track_clicks=).with(email_message.click_tracking_enabled?)
        m.expects(:track_opens=).with(email_message.open_tracking_enabled?)
        m.expects(:message_id=).with(email_message.id.to_s)
        m.expects(:link_encoder=).with(account.link_encoder == 'TWO' ? Java::ComGovdeliveryTmsTmsextended::LinkEncoder::TWO : nil)
        m.stubs(:to).returns([])
      end
    end
    let(:params) {{'message_id' => email_message.id, 'account_id' => account.id}}
    let(:odm_v2) {mock(' Odm::TmsExtendedSenderWorker::ODMv2')}
    let(:odm_service) {stub(' Odm::TmsExtendedSenderWorker::ODMv2_Service', getTMSExtendedPort: odm_v2)}

    context 'dynamic_queue_key' do
      it 'should work with subject' do
        expect(tk_proc = worker.class.get_sidekiq_options['dynamic_queue_key']).to_not eq nil

        expect(tk_proc.call(params)).to eq nil
        expect(tk_proc.call(params.merge('subject' => 'goooo'))).to eq('goooo')
      end
    end

    context 'extended_message_exists?' do
      it 'should return when not retrying' do
        worker.retry_count = nil
        odm_v2.expects(:extended_message_exists?).never
        expect(worker.extended_message_exists?(odm_vendor, '123')).to be(false)
      end
      it 'should call remote service when retrying' do
        worker.retry_count = 10
        odm_v2.expects(:extended_message_exists?).returns(true)
        Odm::TmsExtendedSenderWorker::TMSExtended_Service.expects(:new).returns(odm_service)
        expect(worker.extended_message_exists?(odm_vendor, 123)).to be(true)
      end
    end

    context 'when an extended_message exists' do
      before do
        worker.retry_count = 1
        odm_v2.expects(:extended_message_exists?).returns(true)
        Odm::TmsExtendedSenderWorker::TMSExtended_Service.expects(:new).returns(odm_service)
      end
      it 'should not send the message again' do
        odm_v2.expects(:send_message).never
        worker.perform(params)
      end
    end

    context 'a very happy send with no link_encoder' do
      it 'should work' do
        account.link_encoder = nil
        account.save!
        ExtendedMessage.expects(:new).returns(extended_message)
        odm_v2.expects(:send_message).returns('dummy_id')
        Odm::TmsExtendedSenderWorker::TMSExtended_Service.expects(:new).returns(odm_service)

        worker.perform(params)
        expect(email_message.reload.status).to eq("sending")
      end
      it 'should fail unless message is queued' do
        email_message.cancel!
        expect {worker.perform(params)}.to raise_error(RuntimeError, 
          "EmailMessage #{email_message.id} is not ready for delivery!")
      end
    end

    context 'a very happy send with HYRULE link_encoder' do
      it 'should work' do
        account.link_encoder = 'TWO'
        account.save!
        ExtendedMessage.expects(:new).returns(extended_message)
        odm_v2.expects(:send_message).returns('dummy_id')
        Odm::TmsExtendedSenderWorker::TMSExtended_Service.expects(:new).returns(odm_service)

        worker.perform(params)
        expect(email_message.reload.status).to eq("sending")
      end
      it 'should fail unless message is queued' do
        email_message.cancel!
        expect {worker.perform(params)}.to raise_error(RuntimeError, 
          "EmailMessage #{email_message.id} is not ready for delivery!")
      end
    end

    context 'create_link_encoder with HYRULE' do
      it 'should use HYRULE as the link encoder' do
        expect(worker.send(:create_link_encoder, 'ONE')).to be(Java::ComGovdeliveryTmsTmsextended::LinkEncoder::ONE)
      end
    end

    context 'create_link_encoder with STRONGMAIL' do
      it 'should use STRONGMAIL as the link encoder' do
        expect(worker.send(:create_link_encoder, 'TWO')).to be(Java::ComGovdeliveryTmsTmsextended::LinkEncoder::TWO)
      end
    end

    context 'create_link_encoder with nil' do
      it 'should use nil as the link encoder' do
        expect(worker.send(:create_link_encoder, nil)).to be(nil)
      end
    end

    context 'odm throws error' do
      it 'should catch Throwable and throw Ruby Exception' do
        email_message.stubs(:queued?).returns(true)
        ExtendedMessage.expects(:new).returns(extended_message)
        Odm::TmsExtendedSenderWorker::TMSExtended_Service.expects(:new).returns(odm_service)
        odm_v2.expects(:send_message).raises(Java.java.lang::Exception.new('hello Exception'))

        exception_check(worker, 'hello Exception', params)
      end

      it 'should catch TMSFault and throw Ruby Exception' do
        email_message.stubs(:queued?).returns(true)
        ExtendedMessage.expects(:new).returns(extended_message)
        Odm::TmsExtendedSenderWorker::TMSExtended_Service.expects(:new).returns(odm_service)
        odm_v2.expects(:send_message).raises(
          Java::ComGovdeliveryTmsTmsextended::TMSFault.new('hello TMSFault', nil))

        exception_check(worker, 'hello TMSFault', params)
      end
    end

    context "can't connect to the DB after sending message" do
      it 'should retry marking message as sending' do
        email_message.stubs(:queued?).returns(true)
        ExtendedMessage.expects(:new).returns(extended_message)
        Odm::TmsExtendedSenderWorker::TMSExtended_Service.expects(:new).returns(odm_service)
        odm_v2.expects(:send_message).returns('ack1234')

        worker.class.expects(:mark_sending).raises(ActiveRecord::ConnectionTimeoutError.new('oopz'))
        worker.class.expects(:delay).returns(mock('DelayedClass', mark_sending: 'jid'))

        worker.perform(params)
      end
    end
  end
end
