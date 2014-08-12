require 'spec_helper'
require_relative '../../app/transformers/bart'

describe Transformers::Bart do
  let(:payload) { "<h1>test</h1>" }
  let(:valid_format) { "text/html" }
  let(:invalid_format) { "text/plain" }

  context "with an invalid format" do
    subject do
      Transformers::Bart.new(payload, invalid_format)
    end

    it 'should not have an acceptable format' do
      expect(subject.acceptable_format?).to be(false)
    end

    it 'should return an empty string when returning the transformed data' do
      expect(subject.transform).to be_empty
    end
  end

  context "with a valid format" do
    subject do
      Transformers::Bart.new(payload, valid_format)
    end

    it 'should have an acceptable format' do
      expect(subject.acceptable_format?).to be(true)
    end

    it 'should return an the smsText when returning the transformed data' do
      expect(subject.transform).to eq(payload)
    end
  end
end
