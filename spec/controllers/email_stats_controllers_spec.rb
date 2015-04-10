require 'rails_helper'

[[ClicksController, :click], [OpensController, :open]].each do |klass, stat|
  describe klass do
    let(:email_message) do
      vendor = create(:sms_vendor)
      account = create(:account, sms_vendor: vendor, name: 'name')
      user = account.users.create!(email: 'foo@evotest.govdelivery.com', password: 'schwoop')
      user.email_messages.create!(subject: 'subs', from_name: 'dude', body: 'hi')
    end
    let(:email_recipient) do
      email_message.create_recipients([email: 'dude@sink.govdelivery.com'])
      email_message.recipients.first
    end
    let(:stats) do
      # seven times - once per minute
      7.times.map do |i|
        email_recipient.send(:"#{stat}ed!",
                             'some-ip-or-web-address',
                             Time.at(1_359_784_800 + (i * 60)))
      end
    end

    before do
      sign_in email_message.user
    end

    describe 'GET #index' do
      before do
        # need to invoke since let bindings are lazy and stats isn't used before #get
        stats
      end
      it 'returns http success' do
        get 'index', email_id: email_message.id, recipient_id: email_recipient.id
        expect(response.response_code).to eq(200)
        expect(assigns(:page)).to eq(1)
        expect(assigns(:events).map(&:id).sort).to eq(stats.map(&:id).sort)
        expect(assigns(:events)).to match_array stats
      end
    end

    describe 'GET #show' do
      it 'returns http success' do
        get 'show', email_id: email_message.id, recipient_id: email_recipient.id, id: stats.first.id
        expect(response.response_code).to eq(200)
        expect(assigns(:event)).not_to be_nil
      end
    end
  end
end
