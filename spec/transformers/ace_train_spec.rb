require 'spec_helper'
require_relative '../../app/transformers/ace_train'

describe Transformers::AceTrain do
  let(:valid_json) { {smsText: "Blah"}.to_json }
  let(:invalid_json) { "test" }
  let(:valid_format) { "application/json" }
  let(:invalid_format) { "text/plain" }

  context "with a valid payload" do
    context "and an invalid format" do
      subject do
        Transformers::AceTrain.new(valid_json, invalid_format)
      end

      it 'should not have an acceptable format' do
        expect(subject.acceptable_format?).to be(false)
      end

      it 'should return an empty string when returning the transformed data' do
        expect(subject.transform).to be_empty
      end
    end

    context "and a valid format" do
      subject do
        Transformers::AceTrain.new(valid_json, valid_format)
      end

      it 'should have an acceptable format' do
        expect(subject.acceptable_format?).to be(true)
      end

      it 'should return an the smsText when returning the transformed data' do
        expect(subject.transform).to eq("Blah")
      end
    end
  end

  context "with an invalid payload" do
    context "and invalid format" do
      subject do
        Transformers::AceTrain.new(invalid_json, invalid_format)
      end

      it 'should not have an acceptable format' do
        expect(subject.acceptable_format?).to be(false)
      end

      it 'should return an empty string when returning the transformed data' do
        expect(subject.transform).to be_empty
      end
    end

    context "and a valid format" do
      subject do
        Transformers::AceTrain.new(invalid_json, valid_format)
      end

      it 'should have an acceptable format' do
        expect(subject.acceptable_format?).to be(true)
      end

      it 'should return an empty string when returning the transformed data' do
        expect(subject.transform).to be_empty
      end
    end
  end
end
