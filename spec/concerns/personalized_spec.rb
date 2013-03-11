require File.expand_path('../../little_spec_helper', __FILE__)
require 'active_support'
require 'json'
require File.expand_path('../../../app/concerns/personalized', __FILE__)

class ImportantMessage 
  def self.serialize(attrib, clazz); end
  def self.attr_accessible(*args); end

  include Personalized

  def body
    "[[injections]] here and [[FLUBBER]] there [pea] ugly manhole covers"
  end

end

describe Personalized do
  let(:model) { ImportantMessage.new }
  
  
end
