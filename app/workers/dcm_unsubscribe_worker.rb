class DcmUnsubscribeWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  
  #
  # options: {"from"=>"+14445556666", "params"=>"ACME"}
  #
  def perform(options)
    logger.info("Performing DCM unsubscribe for #{options.inspect}")
  end
end