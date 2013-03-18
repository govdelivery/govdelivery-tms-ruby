require 'spec_helper'

describe InboundMessage do
  let(:vendor) { create_sms_vendor }
  let(:account) { account = vendor.accounts.create!(:name => 'name') }
  let(:keyword) { k=account.keywords.new(:name => "HI").tap { |k| k.vendor = vendor }; k.save!; k }
  let(:command) { c = keyword.add_command!(:command_type => :forward,
                                           :name => "ALLIGATORZ",
                                           :params => CommandParameters.new(:username => 'foo',
                                                                            :password => 'foo',
                                                                            :http_method => 'GET',
                                                                            :url => 'http://www.mom')) }
  let(:command2) { c = keyword.add_command!(:command_type => :forward,
                                            :name => "CROCZZZ",
                                            :params => CommandParameters.new(:username => 'foo',
                                                                             :password => 'foo',
                                                                             :http_method => 'GET',
                                                                             :url => 'http://www.mom')) }

  let(:inbound_message) { InboundMessage.create!(vendor: vendor,
                                                 body: 'this is my body',
                                                 from: '5551112222',
                                                 keyword: keyword) }

  let(:inbound_message_with_response) { InboundMessage.create!(vendor: vendor,
                                                               body: 'this is my body',
                                                               from: '5551112222',
                                                               keyword_response: 'respondzzz') }
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

  it 'should be complete if response is supplied' do
    inbound_message_with_response.command_status.should eq(:success)
  end


  context 'a message saved with a command' do
    before do
      command
      command2
    end
    it 'should be pending' do
      inbound_message.command_status.should eq(:pending)
    end
    context 'and then updated' do
      before do
        command.command_actions.create!(inbound_message_id: inbound_message.id,
                                        http_response_code: 200,
                                        http_content_type: 'text/html')
      end
      it 'should be in progress' do
        inbound_message.reload.command_status.should eq(:pending)
      end

      context 'and then completed' do
        before do
          command.command_actions.create!(inbound_message_id: inbound_message.id,
                                          http_response_code: 204,
                                          http_content_type: 'text/html')
        end
        it 'should be complete' do
          inbound_message.reload.command_status.should eq(:success)
        end
      end

    end
  end

end
