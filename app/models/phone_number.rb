class PhoneNumber
  attr_accessor :number

  def initialize(str)
    self.number = str
  end

  def number=(str)
    @number = PhonyRails.normalize_number(str, :default_country_code => 'US')
  end

  # 1 (444) 333-2222 => +14443332222
  def e164
    number && Phony.formatted(number, :spaces => '')
  end

  # 1 (444) 333-2222 => 1+4443332222
  def dcm
    if number
      country_code, *rest = Phony.split(self.number)
      "#{country_code}+#{rest.join}"
    end
  end
end