module GovDelivery::TMS #:nodoc:
  class FromAddress
    include InstanceResource

    # @!parse attr_accessor :from_email, :reply_to_email, :bounce_email, :is_default
    writeable_attributes :from_email, :from_name, :reply_to_email, :bounce_email, :is_default

    # @!parse attr_reader :id, :created_at
    readonly_attributes :id, :created_at
  end
end
