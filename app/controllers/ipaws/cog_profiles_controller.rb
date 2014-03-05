module IPAWS
  class CogProfilesController < ApplicationController

    include FeatureChecker
    before_filter :find_user
    feature :ipaws

    def show
      respond_with IPAWS::Service.cog_profile
    end

  end
end