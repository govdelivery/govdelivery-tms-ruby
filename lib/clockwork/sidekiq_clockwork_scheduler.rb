require 'celluloid/autostart'
class SidekiqClockworkScheduler
  include Celluloid

  def run
    sleep 20 # wait a bit make surte sidekiq starts processing things
    Sidekiq.logger.info 'Starting Clockwork Thread Fiber'
    Clockwork.run
  rescue => e
    return if e.is_a?(Celluloid::Task::TerminatedError)
    Sidekiq.logger.info "SidekiqClockworkScheduler Thread failed! - #{e.message} \n #{e.backtrace.join("\n")}"
  end
end
