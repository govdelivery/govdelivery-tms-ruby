require 'rails_helper'

describe ApplicationController do
  # See rspec-rails for docs on how to use this.
  # I think it only supports default route methods.
  controller do
    # used to test exception handling
    def show
      raise params[:id].constantize
    end

    def index
      render text: '3oo'
    end
  end

  describe 'when handling exceptions' do
    let(:vendor) {create(:sms_vendor)}
    let(:account) {vendor.accounts.create(name: 'name')}
    let(:user) {account.users.create(email: 'foo@evotest.govdelivery.com', password: 'schwoop')}

    before do
      sign_in user
    end

    it 'should 404 when ActiveRecord::RecordNotFound ' do
      get :show, id: 'ActiveRecord::RecordNotFound'
      expect(response.response_code).to eq(404)
    end

    it 'should 400 on' do
      get :show, id: 'JSON::ParserError'
      expect(response.response_code).to eq(400)
      JSON.parse(response.body) # this shouldn't raise
    end
  end

  describe 'using the X-AUTH-TOKEN header' do
    let(:vendor) {create(:sms_vendor)}
    let(:account) {vendor.accounts.create(name: 'name')}
    let(:user) {account.users.create!(email: 'foo@evotest.govdelivery.com', password: 'schwoop')}
    let(:auth_token) {user.authentication_tokens.first.token}

    before do
      request.headers['X-AUTH-TOKEN'] = auth_token
    end

    it 'should log a user in with that auth token' do
      get :index
      expect(response.response_code).to eq(200)
      expect(controller.current_user).to eq(user)
    end

    describe 'incorrectly' do
      before do
        request.headers['X-AUTH-TOKEN'] = auth_token.succ
      end

      it 'should return the correct response code when token is wrong' do
        get :index
        expect(response.response_code).to eq(401)
      end
    end
  end
end
