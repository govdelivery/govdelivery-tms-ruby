namespace :xact do
  desc 'cancel messages over Rails.configuration.cancelable_message_timeout hours old'
  task cancel_old_messages: :environment do
    [EmailMessage, VoiceMessage, SmsMessage].each do |klass|
      klass.without_message.
        where(status: 'new').
        where('created_at < ?', Rails.configuration.cancelable_message_timeout.ago).find_in_batches do |messages|
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