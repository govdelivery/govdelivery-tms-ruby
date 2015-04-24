require 'rails_helper'

class FooController
  attr_accessor :account
  def self.before_filter(*_args)
  end
  include FeatureChecker
  feature :foo
end

describe FeatureChecker do
  let(:controller) {FooController.new}

  context 'A disabled feature' do
    before do
      controller.account = mock
      controller.account.expects(:feature_enabled?).with(:foo).returns(false)
    end

    it 'should prevent passing through' do
      controller.expects(:render)
      controller.check_if_feature_is_enabled
    end
  end

  context 'An enabled feature' do
    before do
      controller.account = mock
      controller.account.expects(:feature_enabled?).with(:foo).returns(true)
    end

    it 'should pass when feature enabled' do
      controller.expects(:render).never
      controller.check_if_feature_is_enabled
    end
  end
end
