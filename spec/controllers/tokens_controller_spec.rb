require 'rails_helper'
require 'set'

describe TokensController do
  let(:vendor) { create(:sms_vendor) }
  let(:account) { vendor.accounts.create(name: 'name') }
  let(:auth_token) do
    account.users.create(email: 'admin@evotest.govdelivery.com', password: 'schwoop').tap do|u|
      u.admin = true; u.save!
    end.authentication_tokens.first.token
  end
  let(:user) { account.users.create(email: 'foo@evotest.govdelivery.com', password: 'schwoop') }

  before do
    request.headers['X-AUTH-TOKEN'] = auth_token
  end

  it 'allows only admin users' do
    request.headers['X-AUTH-TOKEN'] = user.authentication_tokens.first.token
    get :index, account_id: account.id, user_id: user.id
    expect(response.response_code).to eq(404)
  end

  it 'lists tokens for a user' do
    expected = user.authentication_tokens.map(&:token)
    get :index, account_id: account.id, user_id: user.id
    expect(JSON.parse(response.body)['tokens'].map { |h| h['token'] }.to_set).to eq(expected.to_set)
  end

  it 'shows a token' do
    token = user.authentication_tokens.first
    get :show, account_id: account.id, user_id: user.id, id: token.id
    expect(response.response_code).to eq(200)
  end

  it 'deletes a token' do
    token = user.authentication_tokens.first
    id = token.id
    get :destroy, account_id: account.id, user_id: user.id, id: id
    expect(user.authentication_tokens.find_by_id(id)).to be_nil
    assert_equal 0, user.authentication_tokens.count
    assert user.valid?
  end
end