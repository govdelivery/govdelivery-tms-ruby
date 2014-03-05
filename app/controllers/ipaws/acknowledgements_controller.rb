module IPAWS
  class AcknowledgementsController < ApplicationController

    include FeatureChecker
    before_filter :find_user
    feature :ipaws

    def show
      respond_with({ acknowledgement: IPAWS::Service.ack? })
    end

  end
end