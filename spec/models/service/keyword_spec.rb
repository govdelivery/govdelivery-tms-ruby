require 'rails_helper'

describe Service::Keyword do
  let (:account) { create(:account_with_sms) }

  describe 'with an account, vendor, and special text' do
    ['stop', 'help', 'start'].each do |type|
      context type do

        subject { Service::Keyword.new(type, account.id, account.sms_vendor) }

        it "sets the keyword to the special, #{type} keyword" do
          subject.keyword.should eql account.send(:"#{type}_keyword")
        end

        it "delegates to the response_text set on the #{type} keyword" do
          keyword = account.send(:"#{type}_keyword")
          keyword.response_text = "spatula"
          keyword.save
          subject.response_text.should eql "spatula"
        end

        it "responds with DEFAULT_#{type.upcase}_TEXT if no response_text is set" do
          subject.response_text.should eql Service::Keyword.const_get("DEFAULT_#{type.upcase}_TEXT")
        end

        it "respond! should call #{type}! on account" do
          subject.stubs(:account).returns(account)
          account.expects(:try).with(:"#{type}!", "stuff").returns(true)
          subject.respond!("stuff")
        end
      end
    end
  end

  describe 'with an account, vendor, no special text, and a matching keyword' do

    before do
      @keyword = account.keywords.create(name: "spatula", response_text: "SPATULA")
    end

    subject { Service::Keyword.new("spatula", account.id, account.sms_vendor) }

    it "sets the keyword to the matching keyword" do
      subject.keyword.should eql @keyword
    end

    it "uses the response_text from the keyword" do
      subject.response_text.should eql @keyword.response_text
    end

    it "uses the response_text from the keyword even if the response text is nil" do
      @keyword.response_text = nil
      @keyword.save
      subject.response_text.should eql @keyword.response_text
    end

    it "respond! should call execute_commands on the keyword" do
      subject.stubs(:keyword).returns(@keyword)
      @keyword.expects(:try).with(:execute_commands, "stuff")
      subject.respond!("stuff")
    end
  end

  describe 'with an account, vendor, no special text, and no matching keyword' do

    subject { Service::Keyword.new("spatula", account.id, account.sms_vendor) }

    it "sets the keyword to the default keyword" do
      subject.keyword.should eql account.default_keyword
    end

    it "respond! should call execute_commands on the default keyword" do
      keyword = account.default_keyword
      subject.stubs(:keyword).returns(keyword)
      keyword.expects(:try).with(:execute_commands, "stuff")
      subject.respond!("stuff")
    end
  end

  describe 'with a vendor, no account, and special text' do
    ['stop', 'help', 'start'].each do |type|
      context type do

        let (:vendor) { account.sms_vendor }

        subject { Service::Keyword.new(type, nil, vendor) }

        it "sets no keyword" do
          subject.keyword.should be_nil
        end

        it "responds with DEFAULT_#{type.upcase}_TEXT" do
          subject.response_text.should eql Service::Keyword.const_get("DEFAULT_#{type.upcase}_TEXT")
        end

        it "respond! should call #{type}! on vendor" do
          SmsVendor.any_instance.expects(:try).with(:"#{type}!", "stuff")
          subject.respond!("stuff")
        end
      end
    end
  end

  describe 'with a vendor, no account, and no special text' do

    let (:vendor) { account.sms_vendor }

    subject { Service::Keyword.new("random", nil, account.sms_vendor) }

    it "sets no keyword" do
      subject.keyword.should be_nil
    end

    it "responds with DEFAULT_HELP_TEXT" do
      subject.response_text.should eql Service::Keyword::DEFAULT_HELP_TEXT
    end

    it "respond! should be a noop" do
      SmsVendor.any_instance.expects(:try).times(0)
      Account.any_instance.expects(:try).times(0)
      subject.respond!("stuff")
    end
  end

end