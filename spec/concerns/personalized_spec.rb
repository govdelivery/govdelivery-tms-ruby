require 'spec_helper'
require 'active_support'
require 'json'
require File.expand_path('../../../app/concerns/personalized', __FILE__)

class ImportantMessage
  def self.serialize(attrib); end
  def self.attr_accessible(*args); end
  def self.attr_readonly(*args); end
  def self.validate(*args); end

  include Personalized

  def body
    "[[injections]] here and [[FLUBBER]] there [pea] ugly manhole covers"
  end

end

describe Personalized do
  subject { ImportantMessage.new }
  context 'translating macros' do
    it 'should work' do
      expect(subject.to_odm(:body)).to eq('##injections## here and ##FLUBBER## there [pea] ugly manhole covers')
    end
  end
end
