require 'rails_helper'

describe KeywordCommandsController do
  let(:vendor)  {create(:sms_vendor, name: 'name', username: 'username', password: 'secret', worker: 'LoopbackMessageWorker')}
  let(:account) {vendor.accounts.create! name: 'HELLO ACCOUNT'}
  let(:user)    {account.users.create(email: 'foo@evotest.govdelivery.com', password: 'schwoop')}
  let(:keyword) {create(:keyword, account: account)}
  let(:command) {Command.new(command_type: :dcm_subscribe, name: 'ALLIGATORZ')}
  let(:commands) {[stub(name: 'Hello New York')]}

  before do
    sign_in user
  end

  context "Listing a keyword's commands" do
    before do
      commands.stubs(:page).returns(commands)
      commands.stubs(:total_pages).returns(5)
      Keyword.any_instance.expects(:commands).returns(commands)
    end
    it 'should work on the first page' do
      commands.stubs(:current_page).returns(1)
      commands.stubs(:first_page?).returns(true)
      commands.stubs(:last_page?).returns(false)
      get :index, keyword_id: keyword.id
      expect(response.response_code).to eq(200)
      expect(response.headers['Link']).not_to match(/first/)
      expect(response.headers['Link']).not_to match(/prev/)
      expect(response.headers['Link']).to match(/next/)
      expect(response.headers['Link']).to match(/last/)
    end

    it 'should have all links' do
      commands.stubs(:current_page).returns(2)
      commands.stubs(:first_page?).returns(false)
      commands.stubs(:last_page?).returns(false)
      get :index, keyword_id: keyword.id, page: 2
      expect(response.response_code).to eq(200)
      expect(response.headers['Link']).to match(/first/)
      expect(response.headers['Link']).to match(/prev/)
      expect(response.headers['Link']).to match(/next/)
      expect(response.headers['Link']).to match(/last/)
    end

    it 'should have prev and first links' do
      commands.stubs(:current_page).returns(5)
      commands.stubs(:first_page?).returns(false)
      commands.stubs(:last_page?).returns(true)
      get :index, keyword_id: keyword.id, page: 5
      expect(response.response_code).to eq(200)
      expect(response.headers['Link']).to match(/first/)
      expect(response.headers['Link']).to match(/prev/)
      expect(response.headers['Link']).not_to match(/next/)
      expect(response.headers['Link']).not_to match(/last/)
    end
  end
  context 'Displaying an command' do
    before do
      find = mock
      find.expects(:find).with('22').returns(command)
      Keyword.any_instance.expects(:commands).returns(find)
      get :show, keyword_id: keyword.id, id: '22'
    end
    it 'should work' do
      expect(response.response_code).to eq(200)
    end
  end

  def valid_params
    {
      name:         'Hello Boston',
      command_type: 'dcm_unsubscribe',
      params:       {dcm_account_codes: ['ACME']}
    }
  end

  context 'Creating a command' do
    before do
      Command.any_instance.expects(:save).returns(true)
      Command.any_instance.expects(:new_record?).returns(false)
    end

    it 'should create a command with valid params' do
      post :create, keyword_id: keyword.id, command: valid_params
      expect(response.response_code).to eq(201)
    end

    it 'should be able to create a command on the stop keyword' do
      post :create, keyword_id: 'stop', command: valid_params
      expect(response.response_code).to eq(201)
    end

    it 'should be able to create a command on the help keyword' do
      post :create, keyword_id: 'help', command: valid_params
      expect(response.response_code).to eq(201)
    end

    it 'should be able to create a command on the default keyword' do
      post :create, keyword_id: 'default', command: valid_params
      expect(response.response_code).to eq(201)
    end
  end

  context 'Creating an invalid command' do
    before do
      post :create, keyword_id: keyword.id, command: {
        name: 'Hello Boston',
        command_type: 'dcm_unsubscribe',
        params: {
          dcm_account_codes: ['OOPZ']
        }
      }
    end
    it 'should return error' do
      expect(response.response_code).to eq(422)
    end
  end

  context 'Updating a command' do
    before do
      commands.first.expects(:update_attributes).returns(true)
      commands.first.expects(:valid?).returns(true)
      mock_finder('1')
      put :update, keyword_id: keyword.id, id: '1', command: {
        name: 'Hello Chicago'
      }
    end
    it 'should work' do
      expect(response.response_code).to eq(200)
    end
  end

  context 'Updating an invalid command' do
    before do
      commands.first.expects(:update_attributes).returns(false)
      commands.first.expects(:valid?).returns(false)
      mock_finder('1')
      put :update, keyword_id: keyword.id, id: '1', command: {
        name: 'Hello Chicago'
      }
    end
    it 'should work' do
      expect(response.response_code).to eq(422)
    end
  end

  context 'Deleting a keyword' do
    before do
      commands.first.expects(:destroy)
      mock_finder('1')
      delete :destroy, keyword_id: keyword.id, id: '1'
    end
    it 'should work' do
      expect(response.response_code).to eq(204)
    end
  end

  private

  def mock_finder(id)
    find = mock
    find.expects(:find).with(id).returns(commands.first)
    Keyword.any_instance.expects(:commands).returns(find)
  end
end
