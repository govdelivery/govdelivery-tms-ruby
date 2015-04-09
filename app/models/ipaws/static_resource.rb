module IPAWS
  module StaticResource
    extend ActiveSupport::Concern

    ATTRIBUTES = [:value, :description, :cap_exchange, :core_ipaws_profile, :nwem, :eas_and_public, :cmas]

    included do
      class_attribute :all
      attr_accessor *ATTRIBUTES
    end

    def initialize(attributes = {})
      attributes.each { |k, v| send("#{k}=", v) }
    end
  end
end
