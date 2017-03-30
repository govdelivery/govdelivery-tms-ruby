require 'rails_helper'

describe SessionsController do
  let(:account) {create(:account, name: 'name')}
  let(:user) {account.users.create(email: 'foo@evotest.govdelivery.com', password: 'schwoop')}

  context 'POST #create' do

    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end

    it 'should sign in user when passed a valid one_time_session_token' do
      token = user.one_time_session_token.value
      post :create, { token: token }, format: :json

      expect(response.status).to be(302)
      expect(warden.user(:user)).to eq(user)
      response.should redirect_to root_url
    end

    it 'should fail when passed an invalid one_time_session_token' do
      post :create, { token: "helothere1323" }, format: :json

      expect(response.status).to be(401)
      expect(response.body).to include('Failed to Login')
    end
  end

  context 'DELETE #destroy' do

    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end

    it 'should sign out the user' do
      token = user.one_time_session_token.value
      post :create, { token: token }, format: :json
      expect(warden.user(:user)).to eq(user)

      delete :destroy

      expect(response.status).to be(302)
      expect(warden.user(:user)).to be(nil)
      response.should redirect_to root_url
    end

    it 'should render a failure message if there is no user' do
      delete :destroy
      expect(response.status).to be(200)
      expect(response.body).to include('Logout failed.')
    end
  end
end
