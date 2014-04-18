module IPAWS
  class NwemAreasController < ApplicationController

    include FeatureChecker
    before_filter :find_user
    feature :ipaws

    def index
      respond_with @account.ipaws_vendor.nwem_areas
    end

  end
end