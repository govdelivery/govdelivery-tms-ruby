require 'rails_helper'

RSpec.describe CallScript, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :voice_message }
    it { is_expected.to validate_presence_of :say_text }
  end
end
