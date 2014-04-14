module IPAWS
  class AlertsController < ApplicationController

    include FeatureChecker
    before_filter :find_user
    feature :ipaws

    def create
      render json: @account.ipaws_vendor.post_cap(alert_params)
    end

    private

    def alert_params
      # I could have used wrap_parameters here, but I didn't want to depend
      # on a specific list of attributes.
      params[:alert] || params.except(:controller, :action, :format)
    end
    
  end
end