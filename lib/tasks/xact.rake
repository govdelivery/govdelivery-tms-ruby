namespace :xact do
  desc "cancel messages in NEW or QUEUED status over ENV['MIN_AGE_HOURS'] hours old"
  task cancel_old_messages: :environment do
    raise "MIN_AGE_HOURS must be set to a positive integer" if (hours = ENV['MIN_AGE_HOURS'].to_i) < 1

    [EmailMessage, VoiceMessage, SmsMessage].each do |klass|
      klass.without_message.
        where(status: ['new', 'queued']).
        where('created_at < ?', hours.hours.ago).find_in_batches do |messages|
        klass.transaction do
          messages.each do |message|
            puts "Cancelling #{klass.name} #{message.id}"
            message.cancel!
          end
        end
      end
    end
  end

  desc "set New Relic deployment marker: RPM_APP_ENV=stg RPM_APP_REV='1.13.1' RPM_APP_JIRA='CR-781' rake xact:mark_deployment"
  task :mark_deployment do
    app_id = case ENV['RPM_APP_ENV']
               when 'stg'
                 '2149432'
               when 'prod'
                 '2149789'
               else
                 raise 'RPM_APP_ENV must be either stg or prod'
             end
    raise 'no RPM_APP_REV' unless revision = ENV['RPM_APP_REV'] # e.g. 1.13.1
    raise 'no RPM_APP_JIRA' unless jira = ENV['RPM_APP_JIRA'] # e.g. CR-990

    user    = `whoami`.strip
    api_key = 'b03da1f412e59c426d7f6010e9a30f18fd68b9cee50df6f'

    puts `curl -H "x-api-key:#{api_key}" -d "deployment[application_id]=#{app_id}" -d "deployment[description]=XACT (#{revision}) release (#{jira})" -d "deployment[revision]=#{revision}" -d "deployment[changelog]=#{jira}" -d "deployment[user]=#{user}"  https://rpm.newrelic.com/deployments.xml`
  end

  desc "cancel recipients in NEW status over ENV['MIN_AGE_HOURS'] hours old"
  task cancel_old_recipients: :environment do
    raise "MIN_AGE_HOURS must be set to a positive integer" if (hours = ENV['MIN_AGE_HOURS'].to_i) < 1

    [EmailRecipient, VoiceRecipient, SmsRecipient].each do |klass|
      klass.
        where(status: 'new').
        where('created_at < ?', hours.hours.ago).find_in_batches do |recipients|
        klass.transaction do
          recipients.each do |recipient|
            puts "Cancelling #{klass.name} #{recipient.id}"
            recipient.cancel!
          end
        end
      end
    end
  end
end