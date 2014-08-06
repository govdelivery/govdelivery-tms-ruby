require 'spec_helper'

RSpec.describe CallScript, :type => :model do
  describe 'validations' do
    it { should validate_presence_of :voice_message }
    it { should validate_presence_of :say_text }
  end
end
