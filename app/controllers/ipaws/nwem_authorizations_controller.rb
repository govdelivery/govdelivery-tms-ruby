module IPAWS
  class NwemAuthorizationsController < ApplicationController

    include FeatureChecker
    before_filter :find_user
    feature :ipaws

    def show
      respond_with @account.ipaws_vendor.nwem_cog_authorization
    end

  end
end