require File.expand_path("../../../../app/models/view/recipient_links", __FILE__)
require File.expand_path("../../../little_spec_helper", __FILE__)
require 'active_support/core_ext'

describe View::RecipientLinks do
  describe '#_links' do
    it 'gets correct links for a non-email recipient' do
      message_class = stub(table_name: 'sms_messages', name: 'SmsMessage')
      message = stub(class: message_class)
      recipient = stub(id: 99999, message: message, message_id: 9284375, class: stub(name: 'SmsRecipient'))
      recipient_opts = {
        only_path:  true,
        format:     nil,
        action:     'show',
        controller: 'recipients',
        id:         recipient.id
      }
      message_opts = {
        only_path:  true,
        format:     nil,
        action:     'show',
        controller: message_class.table_name,
        id:         recipient.message_id
      }

      context = stub
      context.expects(:url_for).with(recipient_opts).at_least_once.returns('the self url!!!!!!!!!!')
      context.expects(:url_for).with(message_opts).at_least_once.returns('the message url!!!!!!!!!!')

      recipient_links = View::RecipientLinks.new(recipient, context)
      recipient_links._links[:self].should == 'the self url!!!!!!!!!!'
      recipient_links._links[:sms_message].should == 'the message url!!!!!!!!!!'
    end
    it 'gets correct links for an email recipient' do
      message_class = stub(table_name: 'email_messages', name: 'EmailMessage')
      message = stub(class: message_class)
      recipient = stub(id: 99999, message: message, message_id: 9284375, class: stub(name: 'EmailRecipient'))
      recipient_opts = {
        only_path:  true,
        format:     nil,
        action:     'show',
        controller: 'recipients',
        id:         recipient.id
      }
      message_opts = {
        only_path:  true,
        format:     nil,
        action:     'show',
        controller: message_class.table_name,
        id:         recipient.message_id
      }
      opens_opts = {
        only_path:    true,
        format:       nil,
        action:       'index',
        controller:   'opens',
        email_id:     recipient.message_id,
        recipient_id: recipient.id
      }

      context = stub
      context.expects(:url_for).with(recipient_opts).at_least_once.returns('the self url!!!!!!!!!!')
      context.expects(:url_for).with(message_opts).at_least_once.returns('the message url!!!!!!!!!!')
      context.expects(:url_for).with(opens_opts).at_least_once.returns('the opens url!!!!!!!!!!')

      recipient_links = View::RecipientLinks.new(recipient, context)
      recipient_links._links[:self].should == 'the self url!!!!!!!!!!'
      recipient_links._links[:email_message].should == 'the message url!!!!!!!!!!'
      recipient_links._links[:opens].should == 'the opens url!!!!!!!!!!'
    end
  end
end
