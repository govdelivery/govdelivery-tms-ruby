require 'active_record' # required by phony_rails
require 'phony_rails'

PhoneNumber = Struct.new(:number) do
  # 1 (444) 333-2222 => +14443332222
  def e164
    num = PhonyRails.normalize_number(number, default_country_code: 'US', add_plus: true)
    PhonyRails.plausible_number?(num) ? num : nil
  end

  # 1 (444) 333-2222 => 1+4443332222
  def dcm
    return unless (formatted = e164)
    country_code, *rest = Phony.split(formatted.slice(1..-1))
    [country_code, rest.join].join('+')
  end

  # 468311 => 468311
  # (444) 333-2222 => +14443332222
  def e164_or_short
    return nil if number.blank?
    number.gsub!(/[^\d\+]/, '')
    if number.length == 6 || number.length == 5 # it's a short code
      number
    else
      e164
    end
  end
end
