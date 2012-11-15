require 'spec_helper'

describe Keyword do
  let(:vendor) { Vendor.create!(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker') }
  let(:account) { Account.create!(:name => 'name', :vendor => vendor) }
  let(:keyword) { Keyword.new(:name => "HELPME", :account => account) }
  
  subject { keyword }

  context "when valid" do
    specify { subject.valid?.should == true }
  end

  [:name, :account].each do |field|
    context "when #{field} is empty" do
      before { subject.send("#{field}=", nil) }
      specify { subject.valid?.should == false }
    end
  end

  context "when name is too long" do
    before { subject.name = 'A'*161 }
    specify { subject.should be_invalid }
  end

  context "with duplicate name" do
    before { subject.save! ; @new_keyword = Keyword.new(:name => subject.name, :account => subject.account)}
    specify { @new_keyword.should be_invalid }
  end
end
