require 'rails_helper'

describe IPAWS::ResponseTypesController do

  describe "GET index" do
    it 'returns the array of IPAWS response types' do
      user = create :user, account: create(:account, ipaws_vendor: create(:ipaws_vendor))
      sign_in user
      get :index, format: :json
      response.response_code.should == 200
      expect(response.body).to be_present
      data = JSON.parse(response.body)
      expect(data).to be == IPAWS::ResponseType.all.as_json
    end

    it 'responds with 403 (forbidden) if no IPAWS vendor' do
      user = create :user, account: create(:account, ipaws_vendor: nil)
      sign_in user
      get :index, format: :json
      response.response_code.should == 403
    end
  end

end