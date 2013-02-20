require File.expand_path("../../../../app/models/view/recipient_links", __FILE__)
require File.expand_path("../../../little_spec_helper", __FILE__)
require 'active_support/core_ext'

describe View::RecipientLinks do
  describe '#_links' do
    it 'gets correct links for a non-email recipient' do
      recipient = fake_recipient('sms')
      context = build_context(build_opts(recipient, recipient.message.class))

      recipient_links = View::RecipientLinks.new(recipient, context)._links
      recipient_links[:self].should == 'the recipient url!!!!!!!!!!'
      recipient_links[:sms_message].should == 'the message url!!!!!!!!!!'
    end
    it 'gets correct links for an email recipient' do
      recipient = fake_recipient('email')
      context = build_context(build_opts_with_stats(recipient, recipient.message.class))

      recipient_links = View::RecipientLinks.new(recipient, context)._links
      recipient_links[:self].should == 'the recipient url!!!!!!!!!!'
      recipient_links[:email_message].should == 'the message url!!!!!!!!!!'
      recipient_links[:opens].should == 'the opens url!!!!!!!!!!'
      recipient_links[:clicks].should == 'the clicks url!!!!!!!!!!'
    end

    def build_context(opts)
      context = stub
      opts.each do |name, the_opts|
        context.expects(:url_for).with(the_opts).at_least_once.returns("the #{name} url!!!!!!!!!!")
      end
      context
    end
    def fake_recipient(type)
      message_class = stub(table_name: "#{type.downcase}_messages", name: "#{type.capitalize}Message")
      recipient = stub(id: 99999,
                       message: stub(class: message_class),
                       message_id: 9284375,
                       class: stub(name: "#{type.capitalize}Recipient"))
    end

    def build_opts(recipient, message_class)
      base_opts = base_url_for_opts('show')
      {recipient: base_opts.merge(controller: 'recipients', id: recipient.id),
       message: base_opts.merge(controller: message_class.table_name, id: recipient.message_id)}
    end

    def build_opts_with_stats(recipient, message_class)
      stats_opts = build_stats_opts(recipient.id, recipient.message_id)
      opts = build_opts(recipient, recipient.message.class).merge({
        clicks: stats_opts.merge(controller: 'clicks'),
        opens: stats_opts.merge(controller: 'opens')
      })
    end

    def build_stats_opts(recipient_id, message_id)
      base_url_for_opts('index').merge(email_id: message_id,
                                       recipient_id: recipient_id)
    end

    def base_url_for_opts(action)
      {only_path: true, format: nil, action: action}
    end
  end
end
