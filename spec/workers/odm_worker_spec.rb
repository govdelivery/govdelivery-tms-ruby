require 'spec_helper'
if defined?(JRUBY_VERSION)

  describe OdmWorker do
    let(:odm_vendor) { create_email_vendor(:worker => 'LoopbackMessageWorker') }
    let(:account) { odm_vendor.accounts.create!(:name => 'name') }

    context 'a very happy send' do
      let(:worker) { OdmWorker.new }

      it 'should work' do
        params = {'email' => {'body' => 'msg body',
                              'subject' => 'msg subject',
                              'recipients' => [{'email' => 'email@sink.govdelivery.com'}, {'email' => 'email2@sink.govdelivery.com'}],
                              'from' => 'woop@deedoo.com'},
                  'account_id' => account.id}
        odm_v2 = mock('OdmWorker::ODMv2')
        odm_v2.expects(:send_message).returns('dummy_id')

        odm_service = stub('OdmWorker::ODMv2_Service', :getTMSExtendedPort => odm_v2)
        OdmWorker::TMSExtended_Service.expects(:new).returns(odm_service)

        worker.perform(params)
      end
    end

  end
end