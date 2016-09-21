module GovDelivery
  module Kahlo
    class InvalidMessage < StandardError
      attr_accessor :fields

      def initialize(message, field)
        self.fields = []
        self.fields << field
        super(message)
      end

    end
  end
end
