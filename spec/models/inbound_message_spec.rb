require 'spec_helper'

describe InboundMessage do
  let(:vendor) { Vendor.create(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker') }
  let(:inbound_message) { InboundMessage.create(:vendor => vendor, :body => 'this is my body', :from => '5551112222') }
  subject { inbound_message }

  context "when valid" do
    specify { subject.valid?.should == true }
  end

  [:body, :from].each do |field|
    context "when #{field} is empty" do
      before { subject.send("#{field}=", nil) }
      specify { subject.valid?.should == false }
    end
  end

end
