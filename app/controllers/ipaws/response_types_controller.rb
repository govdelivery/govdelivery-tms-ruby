module IPAWS
  class ResponseTypesController < IPAWS::Controller

    def index
      respond_with ResponseType.all
    end
    
  end
end