require 'rails_helper'

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

  describe 'an HTTP error' do
    subject { build(:command_action,
                    content_type:  nil,
                    response_body: "Service Unavailable",
                    status:        503) }
    it { should be_valid }
  end

  describe 'a network error' do
    subject { build(:command_action,
                    content_type:  nil,
                    error_message: 'Received fatal alert: bad_record_mac',
                    response_body: nil,
                    status:        nil) }
    it { should be_valid }
  end

  describe 'a nothing' do
    subject { build(:command_action, content_type: nil,
                    response_body:                 nil,
                    status:                        nil) }
    it { should_not be_valid }
  end

end
