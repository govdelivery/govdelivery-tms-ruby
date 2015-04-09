module IPAWS
  class CogProfilesController < IPAWS::Controller
    def show
      respond_with @account.ipaws_vendor.cog_profile
    end

    def nwem_authorization
      respond_with @account.ipaws_vendor.nwem_cog_authorization
    end

    def nwem_auxilary_data
      respond_with @account.ipaws_vendor.nwem_auxilary_data
    end
  end
end
