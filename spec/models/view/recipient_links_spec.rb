require File.expand_path('../../../../app/models/view/recipient_links', __FILE__)
require 'spec_helper'
require 'active_support/core_ext'

describe View::RecipientLinks do
  describe '#_links for non-email recipients' do
    let(:recipient) { fake_recipient('sms') }
    let(:context) { build_context(recipient) }
    it 'gets correct links for a non-email recipient' do
      expected_links = { self: 'the recipient url', sms_message: 'the message url' }
      expect(View::RecipientLinks.new(recipient, context)._links).to eq(expected_links)
    end
  end
  describe '#_links for email recipients' do
    let(:recipient) { fake_recipient('email') }
    let(:context) { build_context(recipient) }
    it 'gets correct links for an email recipient' do
      expected_links = { self: 'the recipient url',
                         email_message: 'the message url',
                         clicks: 'the clicks url',
                         opens: 'the opens url' }
      expect(View::RecipientLinks.new(recipient, context)._links).to eq(expected_links)
    end
  end

  def build_context(recipient)
    opts = build_opts(recipient)
    context = stub
    opts.each do |name, the_opts|
      context.expects(:url_for).with(the_opts).at_least_once.returns("the #{name} url")
    end
    context
  end

  def fake_recipient(type)
    message_class = stub(table_name: "#{type.downcase}_messages", name: "#{type.capitalize}Message")
    stub(id: 99_999,
         message: stub(class: message_class),
         message_id: 9_284_375,
         class: stub(name: "#{type.capitalize}Recipient"))
  end

  def build_opts(recipient)
    if recipient.class.name =~ /^email/i
      build_opts_with_stats(recipient, recipient.message.class)
    elsif recipient.class.name =~ /^sms/i
      build_opts_without_stats(recipient, recipient.message.class)
    end
  end

  def build_opts_without_stats(recipient, message_class)
    base_opts = base_url_for_opts('show')
    { recipient: base_opts.merge(controller: 'recipients', id: recipient.id),
      message: base_opts.merge(controller: message_class.table_name, id: recipient.message_id) }
  end

  def build_opts_with_stats(recipient, _message_class)
    base_stats_opts = build_stats_opts(recipient.id, recipient.message_id)
    {
      clicks: base_stats_opts.merge(controller: 'clicks'),
      opens: base_stats_opts.merge(controller: 'opens')
    }.merge(build_opts_without_stats(recipient, recipient.message.class))
  end

  def build_stats_opts(recipient_id, message_id)
    base_url_for_opts('index').merge(email_id: message_id,
                                     recipient_id: recipient_id)
  end

  def base_url_for_opts(action)
    { only_path: true, format: nil, action: action }
  end
end
