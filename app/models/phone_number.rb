require 'active_record' # required by phony_rails
require 'phony_rails'

PhoneNumber = Struct.new(:number) do
  # 1 (444) 333-2222 => +14443332222
  def e164
    wrap { Phony.formatted(formatted, :spaces => '') }
  end

  # 1 (444) 333-2222 => 1+4443332222
  def dcm
    wrap { "#{country_code}+#{without_country_code}" }
  end

  def country_code
    wrap { Phony.split(formatted).first }
  end

  def without_country_code
    wrap { Phony.split(formatted)[1..-1].join }
  end

  private

  def formatted
    PhonyRails.normalize_number(number, :default_country_code => 'US')
  end

  def wrap
    formatted && yield
  end
end
