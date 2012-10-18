require 'spec_helper'

describe Recipient do
  before { @recipient = Recipient.new }
  subject { @recipient }

  context "when phone is empty" do
    before { @recipient.phone = nil }
    specify { @recipient.valid?.should == false }
  end

  context "when phone is not a number" do
    before { @recipient.phone = 'invalid' }
    specify { @recipient.valid?.should == false }
  end
  
  context "when phone contains formatting" do
    before { @recipient.phone = '(651) 555-1212 ' }
    specify { @recipient.valid?.should == true }
  end

  context "when phone is too long" do
    before { @recipient.phone = '5'*25 }
    specify { @recipient.valid?.should == false }
  end

  context "when phone is valid" do
    before { @recipient.phone = '6515551212' }
    context "and country code is empty" do
      before { @recipient.country_code = nil }
      specify { @recipient.valid?.should == true }
    end

    context "and country code is not a number" do
      before { @recipient.country_code = 'xyz' }
      specify { @recipient.valid?.should == true }
    end

    context "and country code is too long" do
      before { @recipient.country_code = '5'*5 }
      specify { @recipient.valid?.should == false }
    end
    
    context "and ack is too long" do
      before { @recipient.ack = 'A'*257 }
      specify { @recipient.valid?.should == false }
    end
  end
end