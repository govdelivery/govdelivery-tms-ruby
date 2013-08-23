require File.dirname(__FILE__) + '/../spec_helper'
require 'set'

describe TokensController do
  let(:vendor) { create(:sms_vendor) }
  let(:account) { vendor.accounts.create(name: 'name') }
  let(:auth_token) {
    account.users.create(email: 'admin@evotest.govdelivery.com', password: "schwoop").tap{|u|
      u.admin = true; u.save!
    }.authentication_tokens.first.token
  }
  let(:user) { account.users.create(email: 'foo@evotest.govdelivery.com', password: "schwoop") }

  before do
    request.env['X-AUTH-TOKEN'] = auth_token
  end

  it 'allows only admin users' do
    request.env['X-AUTH-TOKEN'] = user.authentication_tokens.first.token
    get :index, account_id: account.id, user_id: user.id
    response.response_code.should eq(404)
  end

  it 'lists tokens for a user' do
    expected = user.authentication_tokens.map(&:token)
    get :index, account_id: account.id, user_id: user.id
    JSON.parse(response.body)['tokens'].map{|h| h['token']}.to_set.should eq(expected.to_set)
  end

  it 'deletes a token' do
    token = user.authentication_tokens.first
    id = token.id
    get :destroy, account_id: account.id, user_id: user.id, id: id
    user.authentication_tokens.find_by_id(id).should be_nil
    assert_equal 0, user.authentication_tokens.count
    assert user.valid?
  end
end
