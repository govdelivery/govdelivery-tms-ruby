object @response => 'Response'
attribute :response_text => 'Sms', :if => lambda { |resp| resp.response_text }
