require 'rails_helper'
require_relative '../../../lib/devise/session_strategy.rb'

describe 'One Time Session Authentication', :type => :request do

  context 'post session new' do
    context 'will allow authentication' do
      let(:one_time_session_token){ create(:one_time_session_token) }

      it 'when passed a valid one time session token' do
        # not authenticated
        get '/'
        expect(response.status).to be(401)

        # this post should initiate a session and sets a cookie
        post "/session/new?token=#{one_time_session_token.value}"

        expect(response.status).to be(200)
        expect(response.header).to include('Set-Cookie')

        # authenticated session
        get '/'

        expect(response.status).to be(200)
      end
    end

    context 'will not allow use of invalid tokens' do
      let(:one_time_session_token){ create(:one_time_session_token) }

      it 'does not allow the use of deleted tokens' do
        post "/session/new?token=#{one_time_session_token.value}"
        # destroy existing session
        delete '/session/destroy'

        # redirecting after session/destroy
        expect(response.status).to be(302)

        # cannot reach application root successfully after session/destroy
        get '/'

        expect(response.status).to be(401)

        # a second post with the same token is denied since the token is invalid
        post "/session/new?token=#{one_time_session_token.value}"

        expect(response.status).to be(401)
      end

      it 'does not authenticated posts with an invalid token' do
        # not authenticated
        get '/'
        expect(response.status).to be(401)

        # this post should initiate a session and create a cookie
        post "/session/new?token=12345abcde6789"

        expect(response.status).to be(401)
        expect(response.header).not_to include('Set-Cookie')
      end
    end
  end
end
