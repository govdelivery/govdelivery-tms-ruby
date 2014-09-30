require File.expand_path('../../../rails_helper', __FILE__)

describe 'users/index.rabl' do

  let(:account) { create(:account) }
  let (:user) { create :user, account: account, admin: false }
  let (:admin_user) { create :user, account: account, admin: true }

  before do
    account.users = [user, admin_user]
    assign(:account, account)

  end

  it 'should include all users on the account in the list of users' do
    render
    body = JSON.parse(rendered)
    account.users.each do |a_user|
      body['users'].any?{|body_user| body_user['id'] == a_user.id}.should be_truthy
    end
  end

  it 'should be a good HAL endpoint' do
    render
    body = JSON.parse(rendered)
    body['_links']['self'].should eq(account_users_path(account))
    body['_links']['account'].should eq(account_path(account))
  end
end