module IPAWS
  class ResponseTypesController < ApplicationController

    include FeatureChecker

    before_filter :find_user
    feature :ipaws

    def index
      respond_with ResponseType.all
    end
    
  end
end