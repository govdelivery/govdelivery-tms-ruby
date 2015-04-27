#!/usr/bin/env ruby
require_relative '../config/environment'
require 'thor'

# This script takes a VoiceNessage ID and cancels all calls in sending or inconclusive state.
class TwilioCanceler
  include Celluloid

  def initialize(sid, token)
    account_sid = sid
    auth_token  = token
    @client     = Twilio::REST::Client.new account_sid, auth_token
  end

  def cancel!(recipient)
    # Gotta explicitly check in connections or you'll have problems
    # see https://github.com/celluloid/celluloid/wiki/Gotchas
    ActiveRecord::Base.connection_pool.with_connection do
      @call = @client.account.calls.get(recipient.ack)
      # include in-progress calls; use "canceled" to avoid cancelling calls currently in progress
      @call.update(status: "completed")
      recipient.canceled!(recipient.ack)
      puts "cancel done  #{recipient.id} #{recipient.ack}"
      true
    end
  end

  def self.cancel_all_calls(vm, limit=nil, pool_size=30)
    pool = TwilioCanceler.pool(size: pool_size, args: [vm.vendor.username, vm.vendor.password])
    q    = vm.recipients.where(status: %w{inconclusive sending})
    puts "Total inconclusive + sending recipients: #{q.count}"
    futures = q.limit(limit).map do |recipient|
      puts "cancel async #{recipient.id} #{recipient.ack}"
      pool.future.cancel!(recipient)
    end
    # block until everything returns
    futures.compact.each(&:value)
  end
end

class CancelCallCLI < Thor
  desc 'cancel VOICE_MESSAGE_ID', 'cancel specified call with recipients in progress'
  method_option :limit, aliases: "-l", desc: "Process first n recipients (default is all recipients)", default: nil
  method_option :pool, aliases: "-p", desc: "Max concurrent call cancellation (default 30)", default: 25

  def cancel(voice_message_id)
    vm = VoiceMessage.find(voice_message_id)
    say "VoiceMessage #{vm.id}"
    say "Account #{vm.account.name}"
    say "This will run faster if database.yml pool size matches cancellation pool size (#{options[:pool]})"
    TwilioCanceler.cancel_all_calls(vm, options[:limit], options[:pool])
    say "task complete."
  end
end

CancelCallCLI.start
