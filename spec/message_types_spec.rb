require 'spec_helper'

describe GovDelivery::TMS::MessageTypes do
  context 'loading message types' do
    let(:client) do
      double('client')
    end
    before do
      @message_types = GovDelivery::TMS::MessageTypes.new(client, '/message_types')
    end
    it 'should GET ok' do
      body = [{ 'code' => 'dcm_unsubscribe',
                'label' => 'Unsubcribe' }]
      expect(@message_types.client).to receive(:get).and_return(double('response', body: body, status: 200, headers: {}))
      @message_types.get
      expect(@message_types.collection.length).to eq(1)
      ct = @message_types.collection.first
      expect(ct.code).to eq('dcm_unsubscribe')
      expect(ct.label).to eq('Unsubcribe')
    end
  end
end
