require 'spec_helper'

describe Keyword do
  subject {
    vendor = create(:sms_vendor)
    account = vendor.accounts.create!(:name => 'name', :dcm_account_codes=>["ACME","VANDELAY"])
    keyword = Keyword.new(:name =>'HELPME')
    keyword.account= account
    keyword.vendor = vendor
    keyword
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

  [:name, :response_text].each do |field|
    context "when #{field} is too long" do
      before { subject.send("#{field}=", 'A'*161) }
      specify { subject.should be_invalid }
    end
  end

  context "with duplicate name" do
    before do 
      subject.save!
      @new_keyword = Keyword.new(:name => subject.name)
      @new_keyword.account = subject.account
    end
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

  describe '#add_command!' do
    let(:command){stub('Command', call: true)}
    let(:command_params){CommandParameters.new}

    it 'creates a command' do
      expect{subject.add_command!(:params => CommandParameters.new(:dcm_account_codes => ["ACME","VANDELAY"]), :command_type => :dcm_unsubscribe)}.to change{Command.count}.by 1
    end

    describe '#execute_commands' do
      before do
        subject.expects(:commands).returns([command])
        subject.stubs(:event_handler).returns(true)
      end
      it 'should set account_id and command_id' do
        subject.execute_commands(command_params)
      end
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
