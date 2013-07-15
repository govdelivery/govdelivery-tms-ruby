require 'spec_helper'

describe CommandAction do

  let(:vendor) { create(:sms_vendor) }
  let(:account) { account = vendor.accounts.create!(:name => 'name') }
  let(:keyword) { k=account.keywords.new(:name => "HI").tap { |k| k.vendor = vendor }; k.save!; k }
  let(:command) { c = keyword.add_command!(:command_type => :forward,
                                           :name => "ALLIGATORZ",
                                           :params => CommandParameters.new(:username => 'foo',
                                                                            :password => 'foo',
                                                                            :http_method => 'GET',
                                                                            :url => 'http://www.mom')) }

  let(:inbound_message) { InboundMessage.create!(vendor: vendor,
                                                 body: 'this is my body',
                                                 from: '5551112222',
                                                 keyword: keyword) }

  describe 'a plaintext body' do
    subject {
      CommandAction.create!(inbound_message_id: inbound_message.id,
                            command_id: command.id,
                            status: '201',
                            content_type: 'text/plain; charset=utf-8',
                            response_body: 'body')
    }

    it { should be_valid }
    it { subject.plaintext_body?.should be_true }
    it 'should be false if body is nil' do
      subject.response_body=nil
      subject.plaintext_body?.should be_false
    end
  end

  describe 'an html body' do
    subject {
      CommandAction.create!(inbound_message_id: inbound_message.id,
                            command_id: command.id,
                            status: '404',
                            content_type: 'text/plain; charset=utf-8',
                            response_body: 'body')
    }

    it { should be_valid }
    it { subject.plaintext_body?.should be_false }
  end


end
