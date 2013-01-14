require 'spec_helper'
if defined?(JRUBY_VERSION)

  describe TmsWorker do
    let(:tms_vendor) { create_email_vendor(:worker => 'LoopbackMessageWorker') }
    let(:account) { tms_vendor.accounts.create!(:name => 'name') }

    context 'a very happy send' do
      let(:worker) { TmsWorker.new }

      it 'should work' do
        params = {'email' => {'body' => 'msg body',
                              'subject' => 'msg subject',
                              'recipients' => ['email@sink.govdelivery.com', 'email2@sink.govdelivery.com'],
                              'from' => 'woop@deedoo.com'},
                  'account_id' => account.id}
        odm_v2 = mock('TmsWorker::ODMv2')
        odm_v2.expects(:send_message).returns('dummy_id')

        odm_service = stub('TmsWorker::ODMv2_Service', :getODMv2Port => odm_v2)
        TmsWorker::ODMv2_Service.expects(:new).returns(odm_service)

        worker.perform(params)
      end
    end

  end
end