require 'spec_helper'

describe CommandAction do

  describe 'a plaintext body' do
    subject { build(:command_action, content_type:   'text/plain; charset=utf-8',
                                     response_body:  'something',
                                     status:         '201' ) }
    it { should be_valid }
    it { subject.success?.should be true }
  end

  describe 'a blank response body' do
    subject { build(:command_action, content_type:   'text/plain; charset=utf-8',
                                     response_body:  '',
                                     status:         '201' ) }
    it { should be_valid }
    it { subject.success?.should be false }
  end

  describe 'a response of NOT FOUND' do
    subject { build(:command_action, content_type:   'text/plain; charset=utf-8',
                                     response_body:  'something',
                                     status:         '404' ) }
    it { should be_valid }
    its(:success?) { should be false }
  end

  describe 'an html content type' do
    subject { build(:command_action, content_type:   'text/html; charset=utf-8',
                                     response_body:  'something',
                                     status:         '200' ) }
    it { should be_valid }
    its(:success?) { should be true }
  end

end
