module IPAWS
  class Controller < ApplicationController

    include FeatureChecker
    before_filter :find_user
    around_filter :rescue_from_java

    def self.inherited(subclass)
      subclass.feature :ipaws
    end

    protected

    def rescue_from_java
      yield
    rescue Java::ServicesIpawsFemaGovIpaws_capservice::CAPSoapException => soap
      logger.warn("CAP service error: #{soap.message}")
      logger.warn(soap)
      render json: {error: "the IPAWS service is not available", status_code: '502'}, status: :bad_gateway
    rescue Java::JavaLang::Throwable => throwable
      logger.warn(throwable)
      raise throwable.message
    end

  end
end