module SmsRegressionConfig

  def phone_number_to
    if ENV['XACT_ENV'] == 'qc'
      '+16519684981'
    elsif ENV['XACT_ENV'] == 'integration'
      '+16519641178'
    elsif ENV['XACT_ENV'] == 'stage'
      '+16124247727'
    end
  end

  def phone_number_from
    if ENV['XACT_ENV'] == 'qc'
      '(612) 255-6254'
    elsif ENV['XACT_ENV'] == 'integration'
      '(612) 255-6225'
    elsif ENV['XACT_ENV'] == 'stage'
      '(612) 255-6247'
    end
  end

  extend self
end