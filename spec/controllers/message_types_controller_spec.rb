require 'rails_helper'

RSpec.describe MessageTypesController, type: :controller do
  let(:vendor) {create(:email_vendor, worker: 'LoopbackEmailWorker')}
  let(:account) {create(:account, email_vendor: vendor)}
  let(:user) {account.users.create!(email: 'foo@evotest.govdelivery.com', password: 'schwoop')}
  let(:valid_params) {{label: 'The Salutations message type', code: 'salutations'}}
  let(:message_types) do
    build_list(:message_type, 3, account: account)
  end

  before do
    sign_in user
  end

  context 'index' do
    before do
      stub_pagination(message_types, 2, 5)
      Account.any_instance.expects(:message_types).returns(stub('page', page: message_types))
    end
    it 'should paginate' do
      get :index, page: 2
      expect(assigns(:page)).to eq(2)
      expect(response.headers['Link']).to match(/first/)
      expect(response.headers['Link']).to match(/prev/)
      expect(response.headers['Link']).to match(/next/)
      expect(response.headers['Link']).to match(/last/)
    end
  end

  it 'renders forbidden when feature not enabled' do
    account.email_vendor.destroy!
    get :index
    expect(response.status).to eq(403)
  end

  it 'can create' do
    post :create, message_type: valid_params
    expect(response.status).to eq(201)
    expect(assigns(:message_type)).to be_a(MessageType)
    expect(assigns(:message_type).persisted?).to be true
  end

  it 'can show' do
    message_type = account.message_types.create!(valid_params)
    get :show, id: message_type.to_param
    expect(response.status).to eq(200)
    expect(assigns(:message_type)).to eq(message_type)
  end

  it 'can update :label' do
    message_type = account.message_types.create!(valid_params)
    patch :update, id: message_type.to_param, message_type: valid_params.merge(label: 'something else')
    expect(response.status).to eq(200)
    expect(hook = assigns(:message_type)).to eq(message_type)
    expect(hook.code).to eq('salutations')
    expect(hook.label).to eq('something else')
  end

  it 'can not update :code' do
    message_type = account.message_types.create!(valid_params)
    patch :update, id: message_type.to_param, message_type: valid_params.merge(code: 'oops_nope')
    expect(response.status).to eq(422)
  end

  it 'can destroy' do
    message_type = account.message_types.create(valid_params)
    delete :destroy, id: message_type.to_param
    expect(response.status).to eq(204)
    expect {MessageType.find(message_type.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'can not destroy if :email_messages present' do
    message_type = create(:message_type, account: account)
    _em = create(:email_message,
                 account: account,
                 user: user,
                 message_type_id: message_type.id)
    delete :destroy, id: message_type.to_param
    expect(response.status).to eq(422)
    expect(MessageType.find(message_type.id)).to be_a(MessageType)
  end

  it 'can destroy if :email_templates present but no :email_messages' do
    message_type = create(:message_type, account: account)
    template = create(:email_template, account: account, from_address: account.from_addresses.first, user: user, message_type_id: message_type.id)
    delete :destroy, id: message_type.to_param
    expect(response.status).to eq(204)
    expect {MessageType.find(message_type.id)}.to raise_error(ActiveRecord::RecordNotFound)
    expect(template.reload.message_type).to be(nil)
  end
end
