require 'spec_helper'

describe KeywordBundle do
  let(:exclusive_vendor) { create(:sms_vendor) }
  let(:shared_vendor) { create(:shared_sms_vendor) }
  let(:account_with_shared_vendor1) { create(:account, sms_vendor: shared_vendor) }
  let(:account_with_shared_vendor2) { create(:account, sms_vendor: shared_vendor) }

  describe '#stop_action' do
    
  end
  
  describe '#prefixed_keywords' do
    it 'returns a list of keywords relevant to this body' do
      sms_prefix = account_with_shared_vendor1.sms_prefixes.first
      body = "#{sms_prefix.prefix} OMG"
      kws = [
        shared_vendor.create_keyword!(:account => account_with_shared_vendor1, :name => "whut"),
        shared_vendor.create_keyword!(:account => account_with_shared_vendor1, :name => "omg")
      ]
      # kw from other acct
      shared_vendor.create_keyword!(:account => account_with_shared_vendor2, :name => "hey")
      KeywordBundle.new(shared_vendor, body).prefixed_keywords.should eq(kws)
    end

    it 'returns empty array if no prefix found for shared vendor' do
      body = "NO MATCH OMG" 
      shared_vendor.create_keyword!(:account => account_with_shared_vendor1, :name => "whut")
      KeywordBundle.new(shared_vendor, body).prefixed_keywords.should eq([])
    end

    it 'returns empty array if empty sms body' do
      KeywordBundle.new(shared_vendor, '').prefixed_keywords.should eq([])
    end
  end

  describe '#body_without_prefix' do
    it 'returns sms body without prefix' do
      prefix = account_with_shared_vendor1.sms_prefixes.first.prefix
      sms_body = "#{prefix.capitalize} GOLLY"
      KeywordBundle.new(shared_vendor, sms_body).body_without_prefix.should eq("GOLLY")
    end

    it 'returns sms body without prefix when sms body has leading spaces' do
      prefix = account_with_shared_vendor1.sms_prefixes.first.prefix
      sms_body = "    #{prefix.capitalize} GOLLY"
      KeywordBundle.new(shared_vendor, sms_body).body_without_prefix.should eq("GOLLY")
    end

    it 'should return sms body intact when no prefix detected' do
      KeywordBundle.new(shared_vendor, "NO PREFIX").body_without_prefix.should eq("NO PREFIX")
    end

    it 'returns sms body unchanged when not shared' do
      KeywordBundle.new(exclusive_vendor, "GOODNESS GRACIOUS").body_without_prefix.should eq("GOODNESS GRACIOUS")
    end

    it 'returns nothing if given nothing' do
      KeywordBundle.new(shared_vendor, '').body_without_prefix.should eq('')
      KeywordBundle.new(exclusive_vendor, '').body_without_prefix.should eq('')
    end
  end
end
