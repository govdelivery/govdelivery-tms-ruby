require File.expand_path('../../../app/concerns/mass_assignment', __FILE__)
require File.expand_path('../../../app/models/action_parameters', __FILE__)
require File.expand_path('../../little_spec_helper', __FILE__)

describe ActionParameters do
  let(:params) do
    ActionParameters::PARAMS.inject({}) do |hsh, param|
      hsh.merge(param => "#{param} value")
    end
  end

  let(:action_parameters) { ActionParameters.new(params)}

  it "should convert to hash correctly" do
    hash = action_parameters.to_hash
    ActionParameters::PARAMS.each do |p|
      action_parameters.send(p).should eq("#{p} value")
    end
    action_parameters.account_id = nil
    action_parameters.to_hash.has_key?(:account_id).should == false
  end

  it "should merge correctly" do
    other_parameters = ActionParameters.new(:account_id => 10, :sms_body => nil)

    action_parameters.merge!(other_parameters)

    # properties in other_parameters should replace properties in action_parameters
    action_parameters.account_id.should eq(10)
    
    # nil stuff should not override existing properties
    action_parameters.sms_body.should eq("sms_body value")
  end
end