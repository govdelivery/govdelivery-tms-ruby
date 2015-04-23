require File.expand_path('../../../../../app/models/service/odm/sequence', __FILE__)
require 'spec_helper'

describe Service::Odm::Sequence do
  let(:vendor) {stub(deliveries_sequence: 'a sequence')}
  subject {Service::Odm::Sequence.new(:delivery, vendor)}

  its(:sequence) {should == 'a sequence'}
  it "should update the vendor's sequence" do
    vendor.expects(:update_attributes!).with('deliveries_sequence' => 'a new sequence')
    subject.update_sequence!('a new sequence')
  end
end
