require 'rails_helper'

describe 'routing to email messages' do
  it 'routes to email_messages#create' do
    expect(post('/messages/email')).to route_to('email_messages#create')
  end

  it 'paginates email_messages#index' do
    expect(get('/messages/email/page/1')).to route_to('email_messages#index', page: '1')
  end
end

describe 'routing to email recipients' do
  it 'routes to recipients#clicked' do
    expect(get('/messages/email/1/recipients/clicked')).to route_to('recipients#clicked', email_id: '1')
  end

  it 'routes to recipients#opened' do
    expect(get('/messages/email/1/recipients/opened')).to route_to('recipients#opened', email_id: '1')
  end
end

describe 'routing to email statistics' do
  [:opens, :clicks].each do |stat|
    it "routes to #{stat}#index" do
      expect(get("/messages/email/1/recipients/2/#{stat}")).to route_to("#{stat}#index", email_id: '1', recipient_id: '2')
    end

    it "paginates #{stat}#index" do
      expect(get("/messages/email/1/recipients/2/#{stat}/page/3")).to route_to("#{stat}#index", email_id: '1', recipient_id: '2', page: '3')
    end

    it "routes to #{stat}#show" do
      expect(get("/messages/email/1/recipients/2/#{stat}/1")).to route_to("#{stat}#show", email_id: '1', recipient_id: '2', id: '1')
    end
  end
end
