namespace :xact do
  desc "cancel messages over ENV['MIN_AGE_HOURS'] hours old"
  task cancel_old_messages: :environment do
    raise "MIN_AGE_HOURS must be set to a positive integer" if (hours = ENV['MIN_AGE_HOURS'].to_i) < 1

    [EmailMessage, VoiceMessage, SmsMessage].each do |klass|
      klass.without_message.
        where(status: 'new').
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
end