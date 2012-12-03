module View
  TwilioRequestResponse = Struct.new(:vendor, :response_text) do
    # Delegate missing methods to the vendor object, so that the RablResponder can
    # render appropriate responses based on the status of that model.
    def method_missing(method_name, *args, &block)
      vendor.send(method_name, *args, &block)
    end
  end
end
