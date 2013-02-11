require 'active_support/core_ext'

module Service
  module Odm
    class Sequence
      def initialize(type, vendor)
        @sequence_name = "#{type.to_s.pluralize}_sequence"
        @vendor = vendor
      end
      def sequence
        @vendor.send(@sequence_name)
      end
      def update_sequence!(seq)
        @vendor.update_attributes!(@sequence_name => seq)
      end
    end
  end
end
