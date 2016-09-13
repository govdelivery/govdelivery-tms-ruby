module Service
  module SmsBody
    def annotated(body)
      if Rails.env.production?
        body
      else
        "[#{Rails.env}] #{body.truncate(160-(Rails.env.length+3), omission: "")}"
      end
    end

    module_function :annotated
  end
end