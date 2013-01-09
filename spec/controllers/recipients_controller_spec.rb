require 'spec_helper'

describe RecipientsController do
  let(:vendor) { Vendor.create(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker') }
  let(:account) { vendor.accounts.create(:name => 'name') }
  let(:user) { account.users.create(:email => 'foo@evotest.govdelivery.com', :password => "schwoop") }
  let(:message) { u = user.new_message(:short_body => "A"*160) }
  let(:recipients) do
    3.times.map { |i| message.recipients.build(:phone => (6125551200 + i).to_s) }
  end

  before do
    sign_in user
    User.any_instance.expects(:account_messages).returns(stub(:find => message))
    Message.any_instance.stubs(:id).returns(1)
  end

  context '#index' do
    it 'should work' do
      stub_pagination(recipients, 1, 5)
      Message.any_instance.expects(:recipients).returns(stub(:page => recipients))
      get :index, :sms_id => 1, :format => :json
      assigns(:page).should eq(1)
      response.headers['Link'].should =~ /next/
      response.headers['Link'].should =~ /last/
    end
  end

  context '#page' do
    it 'should work' do
      stub_pagination(recipients, 2, 5)
      Message.any_instance.expects(:recipients).returns(stub(:page => recipients))


      get :index, :sms_id => 1, :format => :json, :page => 2
      assigns(:page).should eq(2)
      response.headers['Link'].should =~ /first/
      response.headers['Link'].should =~ /prev/
      response.headers['Link'].should =~ /next/
      response.headers['Link'].should =~ /last/
    end
  end

  context '#show' do
    it 'should work' do
      stub_pagination(recipients, 2, 5)
      Message.any_instance.expects(:recipients).returns(stub(:find => stub(:find => Recipient.new(:phone => '6125551200'))))

      get :show, :sms_id => 1, :format => :json, :id=> 2
      response.response_code.should == 200
      assigns(:recipient).should_not be_nil
    end
  end

  def stub_pagination(collection, current_page, total_pages)
    recipients.stubs(:current_page).returns(current_page)
    recipients.stubs(:total_pages).returns(total_pages)
    recipients.stubs(:first_page?).returns(current_page == 1)
    recipients.stubs(:last_page?).returns(current_page == total_pages)

  end


end
