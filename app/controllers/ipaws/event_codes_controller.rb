module IPAWS
  class EventCodesController < ApplicationController

    respond_to :json

    def index
      respond_with EventCode.all
    end
    
  end
end