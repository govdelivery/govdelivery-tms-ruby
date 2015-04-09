module CommandType
  class DcmUnsubscribe < Base
    def initialize
      super([], [:dcm_account_codes])
    end
  end
end
