module Service
  module SmsBody
    def annotated(body)
      if Rails.env.production? || !Rails.configuration.non_prod_message_annotations
        body
      else
        "[#{Rails.env}] #{body.truncate(160-(Rails.env.length+3), omission: "")}"
      end
    end

    module_function :annotated
  end
end
