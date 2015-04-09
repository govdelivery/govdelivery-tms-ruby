require 'rails_helper'

describe InboundMessagesController do
  let(:vendor) { create(:sms_vendor) }
  let(:account) { vendor.accounts.create(name: 'name') }
  let(:user) do
    account.users.create(email: 'foo@evotest.govdelivery.com',
                         password: 'schwoop')
  end

  before do
    sign_in user
  end

  describe 'GET index' do
    let(:results) do
      build_list(:inbound_message, 3, vendor: vendor)
    end
    before do
      results.stubs(:total_pages).returns(5)
      controller.stubs(:finder).returns(stub(page: results))
    end
    it 'should work on the first page' do
      results.stubs(:current_page).returns(1)
      results.stubs(:first_page?).returns(true)
      results.stubs(:last_page?).returns(false)
      get :index, format: :json
      expect(response.response_code).to eq(200)
    end

    it 'should have all links' do
      results.stubs(:current_page).returns(2)
      results.stubs(:first_page?).returns(false)
      results.stubs(:last_page?).returns(false)
      get :index, page: 2
      expect(response.headers['Link']).to match(/first/)
      expect(response.headers['Link']).to match(/prev/)
      expect(response.headers['Link']).to match(/next/)
      expect(response.headers['Link']).to match(/last/)
    end

    it 'should have prev and first links' do
      results.stubs(:current_page).returns(5)
      results.stubs(:first_page?).returns(false)
      results.stubs(:last_page?).returns(true)
      get :index, page: 5
      expect(response.headers['Link']).to match(/first/)
      expect(response.headers['Link']).to match(/prev/)
      expect(response.headers['Link']).not_to match(/next/)
      expect(response.headers['Link']).not_to match(/last/)
    end
  end

  describe 'GET show' do
    it 'assigns the requested inbound_message as @message' do
      inbound_message = create(:inbound_message, vendor: vendor, account: account)
      get :show, id: inbound_message.to_param
      expect(response.status).to eq(200)
      expect(assigns(:message)).to be_present
    end
  end

  describe 'index is scoped to account ' do
    before do
      create_list(:inbound_message, 3, vendor: vendor, account: account)
      create_list(:inbound_message, 3, vendor: vendor, account: nil)
    end
    it "shows only inbound_messages of the user's account" do
      get :index
      expect(assigns(:messages).count).to eql(3) # not 6
    end
  end
end
