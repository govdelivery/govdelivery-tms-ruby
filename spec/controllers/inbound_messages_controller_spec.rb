require 'spec_helper'

describe InboundMessagesController do

  # This should return the minimal set of attributes required to create a valid
  # InboundMessage. As you add validations to InboundMessage, be sure to
  # update the return value of this method accordingly.
  let(:valid_attributes) { {:vendor => vendor,
                            :body => 'nice body!',
                            :from => '12345678'} }
  let(:vendor) { create_sms_vendor }
  let(:account){vendor.accounts.create(:name => 'name')}
  let(:user){account.users.create(:email => 'foo@evotest.govdelivery.com',
                                  :password => "schwoop")}

  before do
    sign_in user
  end

  describe "GET index" do
    let(:results) do
      3.times.collect do |i|
        m = InboundMessage.new(valid_attributes.merge(:body => "body #{i}"))
        m.created_at = i.days.ago
      end
    end
    before do
      results.stubs(:total_pages).returns(5)
      SmsVendor.any_instance
        .expects(:inbound_messages)
        .returns(stub(:page => results))
    end
    it "should work on the first page" do
      results.stubs(:current_page).returns(1)
      results.stubs(:first_page?).returns(true)
      results.stubs(:last_page?).returns(false)
      get :index, :format=>:json
      response.response_code.should == 200
    end

    it "should have all links" do
      results.stubs(:current_page).returns(2)
      results.stubs(:first_page?).returns(false)
      results.stubs(:last_page?).returns(false)
      get :index, :page => 2
      response.headers['Link'].should =~ /first/
      response.headers['Link'].should =~ /prev/
      response.headers['Link'].should =~ /next/
      response.headers['Link'].should =~ /last/
    end

    it "should have prev and first links" do
      results.stubs(:current_page).returns(5)
      results.stubs(:first_page?).returns(false)
      results.stubs(:last_page?).returns(true)
      get :index, :page => 5
      response.headers['Link'].should =~ /first/
      response.headers['Link'].should =~ /prev/
      response.headers['Link'].should_not =~ /next/
      response.headers['Link'].should_not =~ /last/
    end
  end

  describe "GET show" do
    it "assigns the requested inbound_message as @inbound_message" do
      inbound_message = InboundMessage.create! valid_attributes
      get :show, {:id => inbound_message.to_param}
      response.status.should == 200
    end
  end

end
