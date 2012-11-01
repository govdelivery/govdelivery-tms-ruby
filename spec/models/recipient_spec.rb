require 'spec_helper'

describe Recipient do
  let(:vendor) { Vendor.create(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker') }

  before { @recipient = Recipient.new ; @recipient.message = Message.new; @recipient.vendor = vendor }
  subject { @recipient }

  context "when phone is empty" do
    before { @recipient.phone = nil }
    specify { @recipient.valid?.should == false }
  end

  context "when phone is not a number" do
    before { @recipient.phone = 'invalid'; @recipient.save! }
    specify { @recipient.valid?.should == true }
    specify { @recipient.formatted_phone.should == nil }
  end
  
  context "when phone contains local formatting" do
    before { @recipient.phone = '(651) 555-1212 ' }
    specify { @recipient.valid?.should == true }

    context "and a country code" do
      before { @recipient.phone = "1 " + @recipient.phone ; @recipient.save! }
      specify { @recipient.formatted_phone.should == '+16515551212' }
    end

    context "will format phone to E.264" do
      before { @recipient.save! }
      specify { @recipient.formatted_phone.should == '+16515551212' }
    end

    context "will not strip local formatting from provided phone" do
      before { @recipient.save! }
      specify { @recipient.phone.should == '(651) 555-1212 ' }
    end
  end

  context "when phone is valid" do
    before { @recipient.phone = '6515551212' }
    
    context "and ack is too long" do
      before { @recipient.ack = 'A'*257 }
      specify { @recipient.valid?.should == false }
    end

    context "and error message is too long" do
      before { @recipient.error_message = 'A'*513 }
      specify { @recipient.valid?.should == true }
    end
  end
end