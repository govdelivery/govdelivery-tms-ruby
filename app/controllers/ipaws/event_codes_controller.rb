module IPAWS
  class EventCodesController < IPAWS::Controller
    def index
      respond_with EventCode.all
    end
  end
end
