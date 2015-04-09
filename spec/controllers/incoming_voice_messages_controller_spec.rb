require 'rails_helper'

describe IncomingVoiceMessagesController do
  let(:account) { create(:account_with_voice) }
  let(:user) do
    account.users.create(email: 'foo@evotest.govdelivery.com',
                         password: 'schwoop')
  end

  before do
    sign_in user
  end

  describe 'GET index' do
    let(:results) do
      build_list(:incoming_voice_message, 3, from_number: account.default_from_number)
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
  end

  describe 'GET show' do
    it 'assigns the requested inbound_message as @message' do
      message = create(:incoming_voice_message, from_number: account.default_from_number)
      get :show, id: message.to_param
      expect(response.status).to eq(200)
      expect(assigns(:voice_message)).to be_present
    end
  end

  describe 'index is scoped to account ' do
    before do
      create_list(:incoming_voice_message, 3, from_number: account.default_from_number)
      create_list(:incoming_voice_message, 3, from_number: nil)
    end
    it "shows only inbound_messages of the user's account" do
      get :index
      expect(assigns(:voice_messages).count).to eql(3) # not 6
    end
  end
end
