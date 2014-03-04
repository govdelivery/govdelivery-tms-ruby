require 'spec_helper'

describe IPAWS::CategoriesController do

  let(:vendor) { create(:sms_vendor) }
  let(:account){vendor.accounts.create(:name => 'name')}
  let(:user){account.users.create(:email => 'foo@evotest.govdelivery.com',
                                  :password => "schwoop")}

  describe "GET index" do
    it 'returns the array of IPAWS categories' do
      sign_in user
      get :index, format: :json
      response.response_code.should == 200
      expect(response.body).to be_present
      data = JSON.parse(response.body)
      expect(data).to be == IPAWS::Category.all.as_json
    end
  end

end