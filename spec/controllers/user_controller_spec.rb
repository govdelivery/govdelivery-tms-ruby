require 'rails_helper'

describe UserController do
  describe 'login' do
    render_views
    let(:user) {create(:user)}
    let(:auth_token) {user.authentication_tokens.first.token}

    context 'correct api token' do
      before do
        request.headers['X-AUTH-TOKEN'] = auth_token
      end

      it 'should return the one time url with the one time token' do
        get :login
        one_time_token = OneTimeSessionToken.find_by_user_id(user.id).value
        expect(response.response_code).to eq(200)
        expect(JSON.parse(response.body)['_links']['self']).to eq 'user/login'
        expect(JSON.parse(response.body)['_links']['session']).to eq '/session/new?token=' + one_time_token
      end
    end

    context 'incorrect api token' do
      before do
        request.headers['X-AUTH-TOKEN'] = auth_token.succ
      end

      it 'should return the correct response code when auth token is wrong' do
        get :login
        expect(response.response_code).to eq(401)
      end
    end

    context 'blank api token' do
      it 'should return the correct response code when auth token is blank' do
        get :login
        expect(response.response_code).to eq(401)
      end
    end
  end
end
