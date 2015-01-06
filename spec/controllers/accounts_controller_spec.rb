require 'rails_helper'

describe AccountsController, :type => :controller do
  let (:account) { create :account,
                          sms_vendor:   create(:sms_vendor),
                          email_vendor: create(:email_vendor),
                          voice_vendor: create(:voice_vendor),
                          ipaws_vendor: create(:ipaws_vendor) }
  let (:user) { create :user, account: account, admin: false }
  let (:admin_user) { create :user, account: account, admin: true }

  context "an admin user" do
    before do
      sign_in admin_user
    end

    context 'who creates an account' do
      before do
        post :create,
             account:      {name:                  'yesss',
                            voice_vendor_id:       create(:voice_vendor).id,
                            email_vendor_id:       create(:email_vendor).id,
                            sms_vendor_id:         create(:sms_vendor).id,
                            ipaws_vendor_id:       create(:ipaws_vendor).id,
                            dcm_account_codes:     ['ACME'],
                            help_text:             'halp',
                            stop_text:             'u stoped',
                            default_response_text: 'foo'},
             from_address: {from_email: 'from@test.com',
                            reply_to:   'reply-to@test.com',
                            errors_to:  'errors-to@test.com'},
             from_number: {phone_number: '8885551234'}
        @account = assigns(:account)
        @account.sms_vendor.should_not be nil
        @account.email_vendor.should_not be nil
        @account.ipaws_vendor.should_not be nil
        @account.voice_vendor.should_not be nil
      end

      it 'should succeed' do
        response.status.should eq(201)
      end

      context 'and then views it' do
        before do
          get :show, id: @account.id
        end
        it 'should succeed' do
          response.status.should eq(200)
        end
      end

      context 'and then deletes it' do
        before do
          delete :destroy, id: @account.id
        end
        it 'should succeed' do
          response.status.should eq(204)
        end
      end

      context 'and then updates it' do
        before do
          patch :update, id: @account.id, account: {name: 'bar'}
        end
        it 'should succeed' do
          response.status.should eq(200)
        end
      end

      context 'and then lists it' do
        before do
          get :index, id: @account.id
        end
        it 'should succeed' do
          response.status.should eq(200)
        end

      end
    end
  end

  context "a non-admin user" do
    before do
      sign_in user
    end
    it 'should not be able to do anything' do
      get :index
      response.status.should eq(403)

      get :show, id: 1
      response.status.should eq(403)

      post :create
      response.status.should eq(403)

      patch :update, id: 1
      response.status.should eq(403)

      delete :destroy, id: 1
      response.status.should eq(403)

    end
  end

end
