module IPAWS
  class AcknowledgementsController < ApplicationController

    include FeatureChecker
    before_filter :find_user
    feature :ipaws

    def show
      respond_with @account.ipaws_vendor.ack
    end

  end
end