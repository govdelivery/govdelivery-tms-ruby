require 'spec_helper'

describe GovDelivery::TMS::SmsMessages do
  context 'creating a new messages list' do
    let(:client) do
      double('client')
    end
    before do
      @messages = GovDelivery::TMS::SmsMessages.new(client, '/messages')
    end
    it 'should GET itself' do
      body = [{ short_body: 'hi ho', created_at: 'a while ago' }, { short_body: 'feel me flow', created_at: 'longer ago' }]
      expect(@messages.client).to receive(:get).and_return(double('response', body: body, status: 200, headers: { 'link' => "</messages/page/2>; rel=\"next\",</messages/page/11>; rel=\"last\"" }))

      @messages.get
      expect(@messages.collection.length).to eq(2)
      expect(@messages.next.href).to eq('/messages/page/2')
      expect(@messages.last.href).to eq('/messages/page/11')
    end
  end
end
