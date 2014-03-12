module IPAWS
  class AcknowledgementsController < IPAWS::Controller

    def show
      respond_with ipaws_client.getAck
    end

  end
end