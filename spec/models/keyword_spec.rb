require 'spec_helper'

describe Keyword do
  subject {
    vendor = Vendor.create!(:name => 'name', :username => 'username', :password => 'secret', :from => 'from', :worker => 'LoopbackMessageWorker')
    account = Account.create!(:name => 'name', :vendor => vendor)
    Keyword.new(:account => account, :vendor => vendor).tap { |kw| kw.name = 'HELPME' }
  }

  context "when valid" do
    specify { subject.valid?.should == true }
  end

  [:name, :account, :vendor].each do |field|
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
    before { subject.save! ; @new_keyword = Keyword.new(:account => subject.account).tap { |kw| kw.name = subject.name }}
    specify { @new_keyword.should be_invalid }
  end

  describe '#name=' do
    it 'downcases the name' do
      subject.name = 'FOOBAR'
      subject.name.should == 'foobar'
    end

    it 'strips whitespace' do
      subject.name = " foobar \n"
      subject.name.should == 'foobar'
    end

    %w(stop quit help).each do |name|
      it "doesn't allow a '#{name}' keyword to be created" do
        subject.name = name
        subject.should_not be_valid
      end

      it "doesn't allow '#{name}' as the first word in a multi-word keyword" do
        subject.name = "#{name} more words"
        subject.should_not be_valid
      end

      it "doesn't allow '#{name}' as the first word in a multi-word keyword separated by non-space characters" do
        subject.name = "#{name}\nmore\nwords"
        subject.should_not be_valid
      end

      it "DOES allow a keyword to start with a word beginning with '#{name}' to be created" do
        subject.name = "#{name}word"
        subject.should be_valid
      end
    end
  end

  describe '#add_action!' do
    it 'creates an action' do
      expect{subject.add_action!(:params => ActionParameters.new(:dcm_account_codes => ["ACME","VANDELAY"]), :action_type => :dcm_unsubscribe)}
        .to change{Action.count}.by 1
    end
  end

  describe 'stop?' do
    %w(stop quit STOP QUIT sToP qUiT cancel unsubscribe).each do |stop|
      it "should recognize #{stop}" do
        Keyword.stop?(stop).should be_true
      end
    end
  end
end
