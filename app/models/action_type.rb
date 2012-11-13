module ActionType

  class DcmUnsubscribe
    def execute(params={})
      DcmUnsubscribeWorker.perform_async(params)
    end
  end
  
end