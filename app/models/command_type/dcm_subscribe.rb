module CommandType
  class DcmSubscribe < Base
    def initialize
      super([:dcm_account_code], [:dcm_topic_codes])
    end
  end
end