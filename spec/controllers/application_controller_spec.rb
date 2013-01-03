require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController do
  controller do
    def show
      raise ActiveRecord::RecordNotFound
    end

  end

  describe "raising an ActiveRecord::RecordNotFound" do
    let(:vendor) { Vendor.create(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker') }
    let(:account) { vendor.accounts.create(:name => 'name') }
    let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
    before do
      sign_in user
    end

    it "should 404" do
      get :show, :id => 1
      response.response_code.should eq(404)
    end
  end
end