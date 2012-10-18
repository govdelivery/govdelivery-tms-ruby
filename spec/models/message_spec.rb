require 'spec_helper'

describe Message do
  before { @message = Message.new }
  subject { @message }
  
  context "when short body is empty" do
    before { @message.short_body = nil }
    specify { @message.valid?.should == false }
  end

  context "when short body is not empty" do
    before { @message.short_body = "A"*160 }
    specify { @message.save.should == true }
  end

  context "when short body is too long" do
    before { @message.short_body = "A"*161 }
    specify { @message.valid?.should == false }
  end
  
  context "accepts nested attributes for recipients" do
    before { @message = Message.new(:short_body => "A"*160, :recipients_attributes => {1 => {:phone => "6515551212"}}) }
    specify { @message.valid?.should == true }
    it { should have(1).recipients }
  end
  
  context "validates recipients before save" do
    before { @message = Message.new(:short_body => "A"*160, :recipients_attributes => {1 => {:phone => "invalid"}}) }
    specify { @message.valid?.should == false }
    it { should have(1).recipients }
  end
end