require File.dirname(__FILE__) + '/../spec_helper'

class Glutcheon
  include MassAssignment

  attr_accessor :foo, :bar, :baz
  attr_accessible :foo, :baz
end

describe MassAssignment do
  let(:model) { Glutcheon.new(:foo => 1, :bar => 1, 'baz' => 45) }

  it "should assign some things and not others" do
    model.foo.should eq(1)
    model.bar.should be_nil
    model.baz.should eq(45)
  end
end
