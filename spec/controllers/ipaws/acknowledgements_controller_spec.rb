require 'spec_helper'

describe IPAWS::AcknowledgementsController do

  describe "GET show" do
    it 'returns true/false based on IPAWS Service getACK request' do
      user = create :user, account: create(:account, ipaws_vendor: create(:ipaws_vendor))
      sign_in user
      get :show, format: :json
      response.response_code.should == 200
      expect(response.body).to be_present
      data = JSON.parse(response.body)
      expect(data).to be == { 'acknowledgement' => false }
    end

    it 'responds with 403 (forbidden) if no IPAWS vendor' do
      user = create :user, account: create(:account, ipaws_vendor: nil)
      sign_in user
      get :show, format: :json
      response.response_code.should == 403
    end
  end

end