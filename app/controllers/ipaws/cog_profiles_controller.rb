module IPAWS
  class CogProfilesController < ApplicationController

    include FeatureChecker
    before_filter :find_user
    feature :ipaws

    def show
      respond_with @account.ipaws_vendor.client.cog_profile
    end

  end
end