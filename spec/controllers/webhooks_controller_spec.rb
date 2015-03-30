require 'rails_helper'

RSpec.describe WebhooksController, :type => :controller do
  let(:account) { Account.create!(name: 'name') }
  let(:user) { account.users.create!(email: 'foo@evotest.govdelivery.com', password: "schwoop") }
  let(:webhooks) do
    3.times.map { |i| account.webhooks.build(event_type: 'failed', url: "http://failwhale.com/fail/#{i}") }
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
      assigns(:page).should eq(2)
      response.headers['Link'].should =~ /first/
      response.headers['Link'].should =~ /prev/
      response.headers['Link'].should =~ /next/
      response.headers['Link'].should =~ /last/
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
    hook.event_type.should eq('sent')
    hook.url.should eq('http://failwhale.com/sent')
  end

  it 'can destroy' do
    webhook = account.webhooks.create!(event_type: 'failed', url: 'http://failwhale.com/fail')
    delete :destroy, id: webhook.to_param
    expect(response.status).to eq(204)
    expect { Webhook.find(webhook) }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
