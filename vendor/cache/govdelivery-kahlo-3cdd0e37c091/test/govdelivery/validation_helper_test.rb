require 'test_helper'

class GovDelivery::Kahlo::ValidationHelperTest < Minitest::Test
  class Validator
    include GovDelivery::Kahlo::ValidationHelper
  end

  def setup
    @subject = Validator.new
  end

  def test_valid_phone?
    assert @subject.valid_phone?("+16122345678")
  end

  def test_valid_phone_or_short_code?
    assert @subject.valid_phone_or_short_code?("+16122345678")
    assert @subject.valid_phone_or_short_code?("11111")
    assert @subject.valid_phone_or_short_code?("22222")
    assert !@subject.valid_phone_or_short_code?("123")
    assert !@subject.valid_phone_or_short_code?("116127227223")
  end

  def test_plausible_from_number?
    assert @subject.plausible_from_number?("+16122345678")
    assert @subject.plausible_from_number?("11111")
    assert @subject.plausible_from_number?("22222")
    assert @subject.plausible_from_number?("loopback")
    assert !@subject.plausible_from_number?("123")
    assert !@subject.plausible_from_number?("116127227223")
  end
end