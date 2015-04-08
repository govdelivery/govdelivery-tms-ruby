require 'rails_helper'

describe CommandTypesController do

  let(:vendor) { create(:sms_vendor) }
  let(:account) { vendor.accounts.create!(name: 'name') }
  let(:user) { account.users.create!(email: 'foo@evotest.govdelivery.com', password: "schwoop") }

  context "a get to index" do
    before do
      sign_in user
      get :index, format: :json
    end

    it "should render correctly" do
      expect(response.response_code).to eq(200)
    end
  end
end
