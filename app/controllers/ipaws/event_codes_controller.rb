module IPAWS
  class EventCodesController < ApplicationController

    include FeatureChecker
    
    before_filter :find_user
    feature :ipaws

    def index
      respond_with EventCode.all
    end
    
  end
end