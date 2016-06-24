require 'rails_helper'

describe MbloxController do
  let(:vendor) { create(:sms_vendor, worker: 'Mblox::SenderWorker') }
  let(:account) { create(:account, sms_vendor: vendor, name: 'name') }
  let(:user) { account.users.create(email: 'foo@evotest.govdelivery.com', password: 'schwoop') }
  let(:message) { user.sms_messages.create(body: 'A' * 160) }

  let (:params) do
    {code: '402', batch_id: "2", recipient: "+161255512001", status: "Awesome"}
  end

  it 'should background the status worker and always succeed' do
    Mblox::StatusWorker.expects(:perform_async).with({status: 'Awesome', code: '402', batch_id: '2', recipient: '+161255512001'}.stringify_keys)
    post :report, params
    expect(response.response_code).to eq(201)
  end
end
