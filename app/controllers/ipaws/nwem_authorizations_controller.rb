module IPAWS
  class NwemAuthorizationsController < IPAWS::Controller

    def show
      respond_with @account.ipaws_vendor.nwem_cog_authorization
    end

  end
end