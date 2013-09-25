require 'spec_helper'

describe InboundSmsContext do
  let(:exclusive_vendor) { create(:sms_vendor) }
  let(:shared_vendor) { create(:shared_sms_vendor) }
  let(:account_with_shared_vendor1) { create(:account, sms_vendor: shared_vendor) }
  let(:account_with_shared_vendor2) { create(:account, sms_vendor: shared_vendor) }
  let(:prefix) { account_with_shared_vendor1.sms_prefixes.first.prefix }

  [:help_text, :stop_text].each do |item|
    describe "##{item}" do
      before do
        account_with_shared_vendor1.send("#{item}=", "not the default for surez")
        account_with_shared_vendor1.save!
      end

      it "should return account #{item} when appropriate" do
        k = InboundSmsContext.new(shared_vendor, "#{prefix} whut")
        k.send(item).should eq(account_with_shared_vendor1.send(item))
      end

      it "should return vendor #{item} when appropriate" do
        k = InboundSmsContext.new(shared_vendor, "undetectable_prefix whut")
        k.send(item).should eq(shared_vendor.send(item))

        k = InboundSmsContext.new(exclusive_vendor, "doesntmatter whut")
        k.send(item).should eq(exclusive_vendor.send(item))      
      end
    end
  end
  describe '#stop_action' do
    it "should return vendor stop when not shared" do
      k = InboundSmsContext.new(exclusive_vendor, 'STOP')
      account_with_shared_vendor2.expects(:stop!).never
      account_with_shared_vendor1.expects(:stop!).never
      exclusive_vendor.expects(:stop!).with(:params)
      k.stop_action.call(:params)
    end
    it "should return vendor stop when shared but account not detected" do
      k = InboundSmsContext.new(shared_vendor, 'FOO STOP')
      account_with_shared_vendor2.expects(:stop!).never
      account_with_shared_vendor1.expects(:stop!).never
      shared_vendor.expects(:stop!).with(:params)
      k.stop_action.call(:params)
    end
    it "should return account stop when shared and account is detected" do
      k = InboundSmsContext.new(shared_vendor, "#{prefix} STOP")
      shared_vendor.expects(:stop!).never
      Account.any_instance.expects(:stop!).with(:params)
      k.stop_action.call(:params)
    end
  end
  
  describe '#keywords' do
    it 'returns a list of keywords relevant to this body' do
      sms_prefix = account_with_shared_vendor1.sms_prefixes.first
      body = "#{sms_prefix.prefix} OMG"
      kws = [
        shared_vendor.create_keyword!(:account => account_with_shared_vendor1, :name => "whut"),
        shared_vendor.create_keyword!(:account => account_with_shared_vendor1, :name => "omg")
      ]
      # kw from other acct
      shared_vendor.create_keyword!(:account => account_with_shared_vendor2, :name => "hey")
      InboundSmsContext.new(shared_vendor, body).keywords.should eq(kws)
    end

    it 'returns empty array if no prefix found for shared vendor' do
      body = "NO MATCH OMG" 
      shared_vendor.create_keyword!(:account => account_with_shared_vendor1, :name => "whut")
      InboundSmsContext.new(shared_vendor, body).keywords.should eq([])
    end

    it 'returns empty array if empty sms body' do
      InboundSmsContext.new(shared_vendor, '').keywords.should eq([])
    end
  end

  describe '#body_without_prefix' do
    it 'returns sms body without prefix' do
      sms_body = "#{prefix.capitalize} GOLLY"
      InboundSmsContext.new(shared_vendor, sms_body).body_without_prefix.should eq("GOLLY")
    end

    it 'returns sms body without prefix when sms body has leading spaces' do
      sms_body = "    #{prefix.capitalize} GOLLY"
      InboundSmsContext.new(shared_vendor, sms_body).body_without_prefix.should eq("GOLLY")
    end

    it 'should return sms body intact when no prefix detected' do
      InboundSmsContext.new(shared_vendor, "NO PREFIX").body_without_prefix.should eq("NO PREFIX")
    end

    it 'returns sms body unchanged when not shared' do
      InboundSmsContext.new(exclusive_vendor, "GOODNESS GRACIOUS").body_without_prefix.should eq("GOODNESS GRACIOUS")
    end

    it 'returns nothing if given nothing' do
      InboundSmsContext.new(shared_vendor, '').body_without_prefix.should eq('')
      InboundSmsContext.new(exclusive_vendor, '').body_without_prefix.should eq('')
    end
  end
end
