require_relative '../../../app/models/view/email_recipient_event'
require_relative '../../little_spec_helper'
require 'active_support/core_ext'
require 'ostruct'

describe View::EmailRecipientEvent do
  describe '#respond_to?' do
    subject { View::EmailRecipientEvent.new(stub(foobar: :omg_lol), nil) }
    it 'works' do
      subject.foobar.should == :omg_lol
      subject.respond_to?(:foobar).should be_true
    end
  end

  describe '#event_at' do
    it 'dispatches to opened_at' do
      t = Time.at(1359784800)
      open = mock(opened_at: t)
      open.stubs(class: stub(name: 'EmailRecipientOpen'))
      subject = View::EmailRecipientEvent.new(open, nil)
      subject.event_at.should == t
    end
    it 'dispatches to clicked_at' do
      t = Time.at(1359784800)
      click = mock(clicked_at: t)
      click.stubs(class: stub(name: 'EmailRecipientClick'))
      subject = View::EmailRecipientEvent.new(click, nil)
      subject.event_at.should == t
    end
  end

  describe '#_links' do
    it 'gets correct links' do
      event = stub(id: 99999, email_message_id: 9284375, email_recipient_id: 12435243)
      context = stub
      context.stubs(:controller_name).returns('opens')
      self_opts = {
        only_path:  true,
        format:     nil,
        controller: context.controller_name,
        action:     'show',
        id:         event.id
      }
      recipient_opts = {
        only_path:  true,
        format:     nil,
        controller: 'recipients',
        action:     'show',
        email_id:   event.email_message_id,
        id:         event.email_recipient_id
      }
      context.expects(:url_for).with(self_opts).at_least_once.returns('the url!!!!!!!!!!')
      context.expects(:url_for).with(recipient_opts).at_least_once.returns('the url!!!!!!!!!!')
      View::EmailRecipientEvent.new(event, context)._links[:self].should == 'the url!!!!!!!!!!'
    end
  end

end


