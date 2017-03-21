require 'rails_helper'

describe UserController do
  describe 'login' do
    let(:one_time_token) {create(:one_time_session_token)}
    let(:auth_token) {one_time_token.user.authentication_tokens.first.token}

    context 'correct api token' do
      before do
        request.headers['X-AUTH-TOKEN'] = auth_token
      end

      it 'should return the one time url with the one time token' do
        get :login
        expect(response.response_code).to eq(200)
        expect(JSON.parse(response.body)).to include '/session/new?token=' + one_time_token.value
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
