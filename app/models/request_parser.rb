class RequestParser
  attr_accessor :vendor, :request_text, :from

  def initialize(vendor, request_text, from)
    self.vendor       = vendor
    self.request_text = request_text
    self.from         = from 
  end

  def parse!
    @vendor.inbound_messages.create!(:from => from, :body => request_text)
    
    if(stop?)
      @vendor.stop!(from)
    end

    self
  end

  # The incoming request body (the thing someone texted to us)
  def request_text
    @request_text || ""
  end

  def stop?
    !!(request_text =~ /stop/i)
  end

  def help?
    !stop?
  end
end