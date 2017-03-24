require 'rails_helper'
require_relative '../../../lib/devise/one_time_session_authentication_api.rb'

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

        expect(response.status).to be(201)
        expect(response.header).to include('Set-Cookie')

        # authenticated session
        get '/'

        expect(response.status).to be(200)
      end
    end

    context 'will not allow use of invalid tokens' do
      let(:one_time_session_token_two){ create(:one_time_session_token) }

      #TODO
      # it 'does not allow the use of deleted tokens' do
      #   # destroy existing session
      #   delete '/session/destroy'
      #
      #   # a second post with the same token is denied
      #   post "/session/new?token=#{one_time_session_token.value}"
      #
      #   expect(response.status).to be(401)
      # end

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
