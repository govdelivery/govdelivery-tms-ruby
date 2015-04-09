module IPAWS
  class AcknowledgementsController < IPAWS::Controller
    def show
      respond_with @account.ipaws_vendor.ack
    end
  end
end
