def it_should_create_a_message(klass, message_opts={}, worker=CreateRecipientsWorker)
  context "#create with a valid sms message" do
    before do
      klass.any_instance.expects(:save).returns(true)
      klass.any_instance.stubs(:new_record?).returns(false)

      worker.expects(:perform_async).with(anything).returns(true)
      post :create, :message => message_opts, :format => :json
    end
    it "should be accepted" do
      response.response_code.should == 201
    end
  end

  context "#create with an invalid sms message" do
    before do
      klass.any_instance.expects(:save).returns(false)
      klass.any_instance.stubs(:new_record?).returns(true)
      post :create, :message => message_opts, :format => :json
    end

    it "should be unprocessable_entity" do
      response.response_code.should == 422
    end
  end
end

def it_should_have_a_pageable_index(klass)
  assoc = klass.to_s.tableize

  context "index" do

    before do
      messages.stubs(:total_pages).returns(5)
      User.any_instance.expects(assoc).returns(stub(:page => messages))
    end
    it "should work on the first page" do
      messages.stubs(:current_page).returns(1)
      messages.stubs(:first_page?).returns(true)
      messages.stubs(:last_page?).returns(false)
      get :index, :format => :json
      response.response_code.should == 200
    end

    it "should have all links" do
      messages.stubs(:current_page).returns(2)
      messages.stubs(:first_page?).returns(false)
      messages.stubs(:last_page?).returns(false)
      get :index, :page => 2
      response.headers['Link'].should =~ /first/
      response.headers['Link'].should =~ /prev/
      response.headers['Link'].should =~ /next/
      response.headers['Link'].should =~ /last/
    end

    it "should have prev and first links" do
      messages.stubs(:current_page).returns(5)
      messages.stubs(:first_page?).returns(false)
      messages.stubs(:last_page?).returns(true)
      get :index, :page => 5
      response.headers['Link'].should =~ /first/
      response.headers['Link'].should =~ /prev/
      response.headers['Link'].should_not =~ /next/
      response.headers['Link'].should_not =~ /last/
    end
  end

end
