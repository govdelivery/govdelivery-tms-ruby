require 'rails_helper'

RSpec.describe UsersController, :type => :controller do

  let (:account) { create :account,
                          sms_vendor:   create(:sms_vendor),
                          email_vendor: create(:email_vendor),
                          voice_vendor: create(:voice_vendor),
                          ipaws_vendor: create(:ipaws_vendor) }
  let (:user) { create :user, account: account, admin: false }
  let (:admin_user) { create :user, account: account, admin: true }

  context "an admin user" do
    before do
      sign_in admin_user
    end

    it 'should be able to list users on an account' do
      get :index, {account_id: account.id}
      expect(response.status).to eq(200)
    end

  end

  context "a non-admin user" do
    before do
      sign_in user
    end

    it 'should not be able to do anything' do
      get :index, {:account_id => account.id}
      expect(response.status).to eq(403)
    end
  end
end
