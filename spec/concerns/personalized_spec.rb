require 'spec_helper'
require 'active_support'
require 'json'
require File.expand_path('../../../app/concerns/personalized', __FILE__)

class ImportantMessage
  def self.serialize(attrib, clazz); end
  def self.attr_readonly(*args); end

  include Personalized

  def body
    "[[injections]] here and [[FLUBBER]] there [pea] ugly manhole covers"
  end

end

describe Personalized do
  subject { ImportantMessage.new }
  context 'translating macros' do
    it 'should work' do
      subject.to_odm(:body).should eq('##injections## here and ##FLUBBER## there [pea] ugly manhole covers')
    end
  end
end
