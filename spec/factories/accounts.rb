FactoryGirl.define do

  factory :account do
    sequence(:name) {|n| "ACME_#{n}" }
    dcm_account_codes ['ACME']

    before(:create) do |account, evaluator|
      evaluator.from_addresses.build({from_email: 'hey@dude.test', is_default: true})
      evaluator.from_numbers.build({phone_number: '8885551234', is_default: true})
    end

    trait :shared do
      sms_vendor factory: :shared_sms_vendor
    end

    factory :account_with_sms do
      sms_vendor factory: :sms_vendor

      ignore do
        prefix 'abc'
      end

      # a prefix must be created first
      before(:create) do |account,evaluator|
        if evaluator.prefix.present?
          sms_prefix = build(:sms_prefix,
                              prefix: evaluator.prefix,
                              sms_vendor: account.sms_vendor)
          sms_prefix.save!
          account.sms_prefixes << sms_prefix
        end

      end
    end

    factory :account_with_voice do
      voice_vendor factory: :voice_vendor
    end

    factory :account_with_stuff do
      sms_vendor factory: :shared_sms_vendor
      email_vendor factory: :email_vendor
      voice_vendor factory: :voice_vendor
      dcm_account_codes ['cia']

      ignore do
        prefix 'abc'
      end

      before(:create) do |account, evaluator|
        if evaluator.prefix.present?
          sms_prefix = build(:sms_prefix,
                             account:    account,
                             prefix:     evaluator.prefix,
                             sms_vendor: account.sms_vendor)
          account.sms_prefixes << sms_prefix
        end

      end

      after(:create) do |account, evaluator|
        keywords = create_list(:keyword, 3, account: account)

        create_list(:dcm_subscribe_command, 1, keyword: keywords[0],
                    params: CommandParameters.new(dcm_account_code: evaluator.dcm_account_codes.first, dcm_topic_codes: ['foo']), command_type: :dcm_subscribe)
        create_list(:dcm_unsubscribe_command, 1, keyword: keywords[1],
                    params: CommandParameters.new(dcm_account_codes: evaluator.dcm_account_codes, dcm_topic_codes: ['foo']), command_type: :dcm_unsubscribe)
        create_list(:forward_command, 1, keyword: keywords[2],
                    params: CommandParameters.new(http_method: 'GET', url: 'http://foo.web'), command_type: :forward)

        create_list(:stop_request, 1, account: account, vendor: account.sms_vendor, phone: account.sms_vendor.from)
        create_list(:webhook, 1, account: account, event_type: 'failed', url: 'http://webhook.org')

        create_list(:user, 1, account: account)

        sms = account.sms_messages.create!(body: 'hi')
        sms.recipients.create!(phone: '16514888888')

        voice = account.voice_messages.create!(say_text: 'hi')
        voice.recipients.create!(phone: '16514888888')

        email               = account.email_messages.create!(body: 'hi', subject: 'sub')
        recipient           = email.recipients.create!(email: 'hi@mom.com')
        click               = recipient.email_recipient_clicks.build
        click.url           = 'http://dude'
        click.clicked_at    = Time.now
        click.email_message = email
        click.email         = recipient.email
        click.save!

        opie               = recipient.email_recipient_opens.build
        opie.email_message = email
        opie.opened_at     = Time.now
        opie.email         = recipient.email
        opie.event_ip      = '128.101.101.101'
        opie.save!
      end
    end
  end

end
