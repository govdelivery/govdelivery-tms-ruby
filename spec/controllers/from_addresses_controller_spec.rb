require 'rails_helper'

RSpec.describe FromAddressesController, type: :controller do
  let(:vendor) {create(:email_vendor, worker: Odm::TMS_EXTENDED_WORKER)}
  let(:account) {create(:account, name: 'name', email_vendor: vendor)}
  let(:user) {account.users.create(email: 'foo@evotest.govdelivery.com', password: 'schwoop')}
  let(:from_address1) {create(:default_from_address, account: account)}
  let(:from_address2) {create(:from_address, account: account)}

  before do
    sign_in user
  end

  context 'an account with an email vendor and from addresses' do
    it 'can list' do
      get :index
      expect(response.response_code).to eq 200
      expect(assigns(:from_addresses)).to_not be nil
    end

    it 'can list' do
      get :show, id: from_address2.id.to_s
      expect(response.response_code).to eq 200
      expect(assigns(:from_address)).to_not be nil
    end

    it 'can page' do
      get :index, page: '2'
      expect(response.response_code).to eq 200
      expect(assigns(:from_addresses)).to_not be nil
      expect(response.headers['Link']).to match(/first/)
      expect(response.headers['Link']).to match(/prev/)
    end
  end
end
