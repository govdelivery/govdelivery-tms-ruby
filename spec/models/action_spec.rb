require 'spec_helper'

describe Action do
  let(:vendor) { Vendor.create!(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker') }
  let(:account) { create_account(vendor: vendor) }
  let(:keyword) { account.stop_keyword }
  let(:action) { Action.new(:keyword => keyword, :account => account, :name => "FOO", :action_type => 1, :params => "PARAMETER OMG") }

  subject { action }

  context "when valid" do
    specify { subject.valid?.should == true }
  end

  [:account, :keyword, :action_type].each do |field|
    context "when #{field} is empty" do
      before { subject.send("#{field}=", nil) }
      specify { subject.valid?.should == false }
    end
  end

  context "when name is too long" do
    before { subject.name = 'A'*256 }
    specify { subject.should be_invalid }
  end
  
  context "when params is too long" do
    before { subject.params = 'A'*4001 }
    specify { subject.should be_invalid }
  end

  context "action_type" do
    specify { subject.action_type_instance.should be_a(Action::ACTION_TYPES[1]) }
  end

  context "execute" do
    before do
      expected = {:params => "PARAMETER OMG", :from => "+122222"}
      Action::ACTION_TYPES[1].any_instance.expects(:execute).with(expected)
    end
    specify { subject.execute(:from => "+122222") }
  end
end
