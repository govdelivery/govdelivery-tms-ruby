require 'rails_helper'

describe Service::Keyword do
  let (:account) { create(:account_with_sms) }

  describe 'with an account, vendor, and special text' do
    ['stop', 'help', 'start'].each do |type|
      context type do

        subject { Service::Keyword.new(type, account.id, account.sms_vendor) }

        it "sets the keyword to the special, #{type} keyword" do
          expect(subject.keyword).to eql account.send(:"#{type}_keyword")
        end

        it "delegates to the response_text set on the #{type} keyword" do
          keyword = account.send(:"#{type}_keyword")
          keyword.response_text = "spatula"
          keyword.save
          expect(subject.response_text).to eql "spatula"
        end

        it "responds with DEFAULT_#{type.upcase}_TEXT if no response_text is set" do
          expect(subject.response_text).to eql Service::Keyword.const_get("DEFAULT_#{type.upcase}_TEXT")
        end

        it "respond! should call #{type}! on account" do
          subject.stubs(:account).returns(account)
          account.expects(:try).with(:"#{type}!", "stuff").returns(true)
          subject.respond!("stuff")
        end

        it "should return false on default?" do
          expect(subject.default?).to eq(false)
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
      expect(subject.keyword).to eql @keyword
    end

    it "uses the response_text from the keyword" do
      expect(subject.response_text).to eql @keyword.response_text
    end

    it "uses the response_text from the keyword even if the response text is nil" do
      @keyword.response_text = nil
      @keyword.save
      expect(subject.response_text).to eql @keyword.response_text
    end

    it "respond! should call execute_commands on the keyword" do
      subject.stubs(:keyword).returns(@keyword)
      subject.expects(:response_text)
      @keyword.expects(:try).with(:execute_commands, "stuff")
      subject.respond!("stuff")
    end

    it "should return false on default?" do
      expect(subject.default?).to eq(false)
    end
  end

  describe 'with an account, vendor, no special text, and no matching keyword' do

    subject { Service::Keyword.new("spatula", account.id, account.sms_vendor) }

    it "sets the keyword to the default keyword" do
      expect(subject.keyword).to eql account.default_keyword
    end

    it "respond! should call execute_commands on the default keyword" do
      keyword = account.default_keyword
      subject.stubs(:keyword).returns(keyword)
      subject.expects(:response_text)
      keyword.expects(:try).with(:execute_commands, "stuff")
      subject.respond!("stuff")
    end

    it "should return true on default?" do
      expect(subject.default?).to eq(true)
    end
  end

  describe 'with a vendor, no account, and special text' do
    ['stop', 'help', 'start'].each do |type|
      context type do

        let (:vendor) { account.sms_vendor }

        subject { Service::Keyword.new(type, nil, vendor) }

        it "sets no keyword" do
          expect(subject.keyword).to be_nil
        end

        it "responds with DEFAULT_#{type.upcase}_TEXT" do
          expect(subject.response_text).to eql Service::Keyword.const_get("DEFAULT_#{type.upcase}_TEXT")
        end

        it "respond! should call #{type}! on vendor" do
          SmsVendor.any_instance.expects(:try).with(:"#{type}_text")
          SmsVendor.any_instance.expects(:try).with(:"#{type}!", "stuff")
          subject.respond!("stuff")
        end

        it "should return false on default?" do
          expect(subject.default?).to eq(false)
        end
      end
    end
  end

  describe 'with a vendor with custom response text, no account, and special text' do
    ['stop', 'help', 'start'].each do |type|
      context type do

        let (:vendor) do
          vendor = account.sms_vendor
          vendor.send(:"#{type}_text=", 'custom')
          vendor.save!
          vendor
        end

        subject { Service::Keyword.new(type, nil, vendor) }

        it "responds with #{type}_text" do
          expect(subject.response_text).to eql 'custom'
        end
      end
    end
  end

  describe 'with a vendor with custom response text, no account, and no special text', test: true do
    let (:vendor) do
      vendor = account.sms_vendor
      vendor.help_text = "custom"
      vendor.save!
      vendor
    end

    subject { Service::Keyword.new("random", nil, vendor) }

    it "should respond with the custom help_text" do
      expect(subject.response_text).to eql 'custom'
    end
  end

  describe 'with a vendor, no account, and no special text' do

    let (:vendor) { account.sms_vendor }

    subject { Service::Keyword.new("random", nil, account.sms_vendor) }

    it "sets no keyword" do
      expect(subject.keyword).to be_nil
    end

    it "responds with DEFAULT_HELP_TEXT" do
      expect(subject.response_text).to eql Service::Keyword::DEFAULT_HELP_TEXT
    end

    it "respond! should be a noop" do
      SmsVendor.any_instance.expects(:try).with(:help_text)
      Account.any_instance.expects(:try).times(0)
      subject.respond!("stuff")
    end

    it "should return true on default?" do
      expect(subject.default?).to eq(true)
    end
  end

end