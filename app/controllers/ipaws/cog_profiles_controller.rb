module IPAWS
  class CogProfilesController < IPAWS::Controller

    def show
      respond_with ipaws_client.getCOGProfile
    end

  end
end