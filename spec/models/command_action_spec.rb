require 'rails_helper'

describe CommandAction do
  describe 'a plaintext body' do
    subject do
      build(:command_action, content_type:   'text/plain; charset=utf-8',
                             response_body:  'something',
                             status:         '201')
    end
    it { is_expected.to be_valid }
    it { expect(subject.success?).to be true }
  end

  describe 'a blank response body' do
    subject do
      build(:command_action, content_type:   'text/plain; charset=utf-8',
                             response_body:  '',
                             status:         '201')
    end
    it { is_expected.to be_valid }
    it { expect(subject.success?).to be false }
  end

  describe 'a response of NOT FOUND' do
    subject do
      build(:command_action, content_type:   'text/plain; charset=utf-8',
                             response_body:  'something',
                             status:         '404')
    end
    it { is_expected.to be_valid }
    its(:success?) { should be false }
  end

  describe 'an html content type' do
    subject do
      build(:command_action, content_type:   'text/html; charset=utf-8',
                             response_body:  'something',
                             status:         '200')
    end
    it { is_expected.to be_valid }
    its(:success?) { should be true }
  end

  describe 'an HTTP error' do
    subject do
      build(:command_action,
            content_type:  nil,
            response_body: 'Service Unavailable',
            status:        503)
    end
    it { is_expected.to be_valid }
  end

  describe 'a network error' do
    subject do
      build(:command_action,
            content_type:  nil,
            error_message: 'Received fatal alert: bad_record_mac',
            response_body: nil,
            status:        nil)
    end
    it { is_expected.to be_valid }
  end

  describe 'a nothing' do
    subject do
      build(:command_action, content_type: nil,
                             response_body:                 nil,
                             status:                        nil)
    end
    it { is_expected.not_to be_valid }
  end
end
