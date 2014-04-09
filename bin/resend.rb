require 'benchmark'

class Resend

  BATCH_SIZE = 100

  USERS = Hash.new { |hash, id| hash[id] = User.find(id.to_i) }

  def initialize
    @quit = false
  end

  def quit!
    if @quit
      exit
    else
      puts "Quitting after batch ..."
      @quit = true
    end
  end

  def wait_for_sidekiq_queue_to_be_empty
    while (Sidekiq::Queue.new.size > 0)
      @stdout_logger.debug "Sidekiq::Queue.new.size is #{Sidekiq::Queue.new.size}"
      sleep 1
    end
  end

  def resend_email_stream(email_id_stream)
    @stdout_logger = Logger.new(STDOUT)
    @already_sent = Set.new
    if File.exists?('sent.log')
      File.open("sent.log").each_line { |line| @already_sent << line.split.first.to_i if line.present? }
    end
    @stdout_logger.debug "Already sent #{@already_sent.size} emails"
    @sent_logger = Logger.new('sent.log')
    @failed_logger = Logger.new('failed.log')
    benchmark = Benchmark.measure do
      while !email_id_stream.eof?
        return if @quit
        wait_for_sidekiq_queue_to_be_empty
        email_ids = BATCH_SIZE.times.map{email_id_stream.gets.try(:chomp)}.compact
        resend_emails_concurrenty(email_ids)
      end
    end
    @stdout_logger.debug benchmark.to_s
    @sent_logger.close
    @failed_logger.close
  end

  def resend_emails_concurrenty(email_ids)
    executor = Java::java.util.concurrent.Executors.newFixedThreadPool(32)
    futures = email_ids.map { |id|
      task = proc do
        resend_email(id)
      end
      executor.submit(task)
    }
    futures.each {|future|
      future.get
    }
    executor.shutdown
  end

  def resend_email(email_id)
    email_id = email_id.to_i
    if @already_sent.include?(email_id)
      @stdout_logger.debug "Skipping ##{email_id} because it was already sent"
      return
    end
    email, saved = nil, false
    ActiveRecord::Base.connection_pool.with_connection do
      email = copy_email(EmailMessage.find(email_id))
      saved = email.save_with_async_recipients
    end
    if saved
      CreateRecipientsWorker.perform_async(
        :recipients => email.async_recipients,
        :klass => email.class.name,
        :message_id => email.id,
        :send_options => {}
      )
      @sent_logger.debug("#{email_id} #{email.id}")
      @stdout_logger.debug "Queued resend of message ##{email_id} as ##{email.id}"
    else
      @stdout_logger.debug "Could not save copy of ##{email_id}: #{email.errors.full_messages.join ', '}"
      @failed_logger.debug "MESSAGE_IDS::#{email_id}\n#{email.errors.full_messages.inspect}"
    end
  rescue
    @stdout_logger.debug "Error resending email ##{email_id}: #{$!.message}"
    @failed_logger.debug "MESSAGE_IDS::#{email_id} #{email.try(:id) || 'nil'}\n#{$!.message}\n#{$!.backtrace.join("\n")}"
  end

  def copy_email(original)
    email = EmailMessage.new
    email.user = original.user #USERS[original.user_id]
    email.account = email.user.account 
    email.body = original.body
    email.from_name = original.from_name
    email.subject = original.subject
    email.open_tracking_enabled = original.open_tracking_enabled
    email.click_tracking_enabled = original.click_tracking_enabled
    email.macros = original.macros
    email.async_recipients = original.recipients.map { |recipient| recipient.attributes.slice('email') }
    email
  end

end

if __FILE__ == $0
  file = File.open(ARGV.first, 'r')
  require File.expand_path("../../config/environment", __FILE__)
  resend = Resend.new
  trap('INT') do
    resend.quit!
  end
  resend.resend_email_stream(file)
end
