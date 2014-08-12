require 'rails_helper'

describe Transformer do
  let (:account) { create(:account) }
  it { should belong_to(:account) }

  context "transform" do
    subject {
      create(:transformer, account: account)
    }

    it "should call the underlying transformer object's method" do
      transformer_object = mock()
      transformer_object.stubs(:transform)
      subject.stubs(:get_transformer).returns(transformer_object)
      transformer_object.expects(:transform)
      subject.transform("junk", "junk")
    end
  end
end