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