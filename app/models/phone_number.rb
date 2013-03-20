require 'active_record' # required by phony_rails
require 'phony_rails'

PhoneNumber = Struct.new(:number) do
  # 1 (444) 333-2222 => +14443332222
  def e164
    formatted && Phony.formatted(formatted, :spaces => '')
  end

  # 1 (444) 333-2222 => 1+4443332222
  def dcm
    if formatted
      country_code, *rest = Phony.split(formatted)
      "#{country_code}+#{rest.join}"
    end
  end

  # 468311 => 468311
  # (444) 333-2222 => +14443332222
  def e164_or_short
    return number if number.blank?
    number.gsub!(/[^\d\+]/, '')
    if number.length == 6 #it's a short code
      number
    else
      '+' + formatted
    end
  end

  private

  def formatted
    PhonyRails.normalize_number(number, :default_country_code => 'US')
  end
end
