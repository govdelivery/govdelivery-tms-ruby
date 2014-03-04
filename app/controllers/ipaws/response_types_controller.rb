module IPAWS
  class ResponseTypesController < ApplicationController

    respond_to :json

    def index
      respond_with ResponseType.all
    end
    
  end
end