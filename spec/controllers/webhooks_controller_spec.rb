require 'rails_helper'

RSpec.describe WebhooksController, type: :controller do
  let(:account) {Account.create!(name: 'name')}
  let(:user) {account.users.create!(email: 'foo@evotest.govdelivery.com', password: 'schwoop')}
  let(:webhooks) do
    3.times.map { |i| account.webhooks.build(event_type: 'failed', url: "http://failwhale.com/fail/#{i}")}
  end

  before do
    sign_in user
  end

  context 'index' do
    before do
      stub_pagination(webhooks, 2, 5)
      Account.any_instance.expects(:webhooks).returns(stub('page', page: webhooks))
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

  it 'can create' do
    post :create, webhook: {event_type: 'failed', url: 'http://failwhale.com/fail'}
    expect(response.status).to eq(201)
    expect(assigns(:webhook)).to be_a(Webhook)
    expect(assigns(:webhook).persisted?).to be true
  end

  it 'can show' do
    webhook = account.webhooks.create!(event_type: 'failed', url: 'http://failwhale.com/fail')
    get :show, id: webhook.to_param
    expect(response.status).to eq(200)
    expect(assigns(:webhook)).to eq(webhook)
  end

  it 'can update' do
    webhook = account.webhooks.create!(event_type: 'failed', url: 'http://failwhale.com/fail')
    patch :update, id: webhook.to_param, webhook: {event_type: 'sent', url: 'http://failwhale.com/sent'}
    expect(response.status).to eq(200)
    expect(hook = assigns(:webhook)).to eq(webhook)
    expect(hook.event_type).to eq('sent')
    expect(hook.url).to eq('http://failwhale.com/sent')
  end

  it 'can destroy' do
    webhook = account.webhooks.create!(event_type: 'failed', url: 'http://failwhale.com/fail')
    delete :destroy, id: webhook.to_param
    expect(response.status).to eq(204)
    expect {Webhook.find(webhook.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end
end
