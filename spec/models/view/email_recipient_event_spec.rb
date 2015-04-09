require_relative '../../../app/models/view/email_recipient_event'
require 'spec_helper'
require 'active_support/core_ext'
require 'ostruct'

describe View::EmailRecipientEvent do
  describe '#respond_to?' do
    subject { View::EmailRecipientEvent.new(stub(foobar: :omg_lol), nil) }
    it 'works' do
      expect(subject.foobar).to eq(:omg_lol)
      expect(subject.respond_to?(:foobar)).to be true
    end
  end

  describe '#event_at' do
    it 'dispatches to opened_at' do
      t = Time.zone.at(1_359_784_800)
      open = mock(opened_at: t)
      open.stubs(class: stub(name: 'EmailRecipientOpen'))
      subject = View::EmailRecipientEvent.new(open, nil)
      expect(subject.event_at).to eq(t)
    end
    it 'dispatches to clicked_at' do
      t = Time.zone.at(1_359_784_800)
      click = mock(clicked_at: t)
      click.stubs(class: stub(name: 'EmailRecipientClick'))
      subject = View::EmailRecipientEvent.new(click, nil)
      expect(subject.event_at).to eq(t)
    end
  end

  describe '#_links' do
    it 'gets correct links' do
      event = stub(id: 99_999, email_message_id: 9_284_375, email_recipient_id: 12_435_243)
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
      context.expects(:url_for).with(self_opts).at_least_once.returns('the self url!!!!!!!!!!')
      context.expects(:url_for).with(recipient_opts).at_least_once.returns('the recipient url!!!!!!!!!!')
      event_view = View::EmailRecipientEvent.new(event, context)
      expect(event_view._links[:self]).to eq('the self url!!!!!!!!!!')
      expect(event_view._links[:email_recipient]).to eq('the recipient url!!!!!!!!!!')
    end
  end
end
