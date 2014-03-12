require 'spec_helper'

describe IPAWS::AcknowledgementsController do

  let(:sample_ack) do
    { 'ACK' => 'PONG' }
  end

  describe "GET show" do
    it 'returns true/false based on IPAWS Service getACK request' do
      IPAWSClient.any_instance.stubs(:getAck).returns(sample_ack)
      user = create :user, account: create(:account, ipaws_enabled: true)
      sign_in user
      get :show, format: :json
      response.response_code.should == 200
      expect(response.body).to be_present
      data = JSON.parse(response.body)
      expect(data).to be == sample_ack
    end

    it 'responds with 403 (forbidden) if no IPAWS vendor' do
      user = create :user, account: create(:account, ipaws_enabled: false)
      sign_in user
      get :show, format: :json
      response.response_code.should == 403
    end
  end

end