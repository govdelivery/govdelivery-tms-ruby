module IPAWS
  class NwemAreasController < IPAWS::Controller
    def index
      respond_with @account.ipaws_vendor.nwem_areas
    end
  end
end
