require 'rails_helper'

RSpec.shared_examples 'an account endpoint' do
  it 'should succeed' do
    expect(response.status).to eq(201)
  end

  context 'and then views it' do
    before do
      get :show, id: @account.id
    end
    it 'should succeed' do
      expect(response.status).to eq(200)
    end
  end

  context 'and then deletes it' do
    before do
      delete :destroy, id: @account.id
    end
    it 'should succeed' do
      expect(response.status).to eq(204)
    end
  end

  context 'and then updates it' do
    before do
      patch :update, id: @account.id, account: { name: 'bar' }
    end
    it 'should succeed' do
      expect(response.status).to eq(200)
    end
  end

  context 'and then lists it' do
    before do
      get :index, id: @account.id
    end
    it 'should succeed' do
      expect(response.status).to eq(200)
    end
  end
end

describe AccountsController, type: :controller do
  let(:account) do
    create :account,
           sms_vendor:   create(:sms_vendor),
           email_vendor: create(:email_vendor),
           voice_vendor: create(:voice_vendor),
           ipaws_vendor: create(:ipaws_vendor)
  end
  let(:user) { create :user, account: account, admin: false }
  let(:admin_user) { create :user, account: account, admin: true }

  context 'an admin user' do
    before do
      sign_in admin_user
    end

    context 'who creates an account with a nested request' do
      before do
        post :create,
             account:      { name:                  'yesss',
                             voice_vendor_id:       create(:voice_vendor).id,
                             email_vendor_id:       create(:email_vendor).id,
                             sms_vendor_id:         create(:sms_vendor).id,
                             ipaws_vendor_id:       create(:ipaws_vendor).id,
                             dcm_account_codes:     ['ACME'],
                             help_text:             'halp',
                             stop_text:             'u stoped',
                             default_response_text: 'foo',
                             link_tracking_parameters: 'foo=bar' },
             from_address: { from_email: 'from@test.com',
                             reply_to:   'reply-to@test.com',
                             errors_to:  'errors-to@test.com' },
             from_number: { phone_number: '8885551234' }
        @account = assigns(:account)
        expect(@account.sms_vendor).to_not be nil
        expect(@account.email_vendor).to_not be nil
        expect(@account.ipaws_vendor).to_not be nil
        expect(@account.voice_vendor).to_not be nil
      end

      it_behaves_like 'an account endpoint'
    end

    context 'who creates an account with a flat request' do
      before do
        post :create,
             name:                  'yesss',
             voice_vendor_id:       create(:voice_vendor).id,
             email_vendor_id:       create(:email_vendor).id,
             sms_vendor_id:         create(:sms_vendor).id,
             ipaws_vendor_id:       create(:ipaws_vendor).id,
             dcm_account_codes:     ['ACME'],
             help_text:             'halp',
             stop_text:             'u stoped',
             default_response_text: 'foo',
             link_tracking_parameters: 'foo=bar',
             from_email: 'from@test.com',
             reply_to:   'reply-to@test.com',
             errors_to:  'errors-to@test.com',
             phone_number: '8885551234'
        @account = assigns(:account)
        expect(@account.sms_vendor).to_not be nil
        expect(@account.email_vendor).to_not be nil
        expect(@account.ipaws_vendor).to_not be nil
        expect(@account.voice_vendor).to_not be nil
      end

      it_behaves_like 'an account endpoint'
    end

    context 'who creates an account with a nils on non-email fields' do
      before do
        post :create,
             name:                  'yesss',
             voice_vendor_id:       nil,
             email_vendor_id:       create(:email_vendor).id,
             sms_vendor_id:         nil,
             ipaws_vendor_id:       nil,
             dcm_account_codes:     ['ACME'],
             help_text:             nil,
             stop_text:             nil,
             default_response_text: nil,
             link_tracking_parameters: nil,
             from_email: 'from@test.com',
             reply_to:   nil,
             errors_to:   nil,
             phone_number: nil
        @account = assigns(:account)
        expect(@account.sms_vendor).to be nil
        expect(@account.email_vendor).to_not be nil
        expect(@account.ipaws_vendor).to be nil
        expect(@account.voice_vendor).to be nil
      end

      it_behaves_like 'an account endpoint'
    end
  end

  context 'a non-admin user' do
    before do
      sign_in user
    end
    it 'should not be able to do anything' do
      get :index
      expect(response.status).to eq(403)

      get :show, id: 1
      expect(response.status).to eq(403)

      post :create
      expect(response.status).to eq(403)

      patch :update, id: 1
      expect(response.status).to eq(403)

      delete :destroy, id: 1
      expect(response.status).to eq(403)
    end
  end
end
