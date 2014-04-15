module IPAWS
  class Vendor < ActiveRecord::Base

    if defined?(JRUBY_VERSION)
      java_import com.govdelivery.ipaws.IPAWSClient
    end

    self.table_name = 'ipaws_vendors'

    has_many :accounts, foreign_key: :ipaws_vendor_id, inverse_of: :ipaws_vendor

    validates :cog_id, :user_id, :public_password_encrypted, :private_password_encrypted, :jks, presence: true 

    attr_encrypted :public_password, attribute: :public_password_encrypted
    attr_encrypted :private_password, attribute: :private_password_encrypted

    delegate :ack, :cog_profile, to: :client

    def post_cap(attributes)
      # postCAP needs the attributes "sanitized" with as_json to remove symbols.
      reform_cap_response(client.postCAP(attributes.as_json))
    end

    def client(reload=false)
      @client = nil if reload
      @client ||= begin
        write_jks_file
        IPAWSClient.new(cog_id, user_id, jks_path, public_password, private_password)
      end
    end

    private

    def reform_cap_response(cap_response)
      # The CAP response provided by FEMA is in a strange format:  
      # 1. The response attributes are not structurally grouped.
      # 2. The response attributes are not themselves under any sort of key (empty string).
      cap_response = cap_response.as_json
      if responses = cap_response.delete('')
        cap_response['responses'] = responses.in_groups_of(4, fill = false).map do |group|
          group.inject { |response, attributes| response.merge(attributes) }
        end
      end
      cap_response
    end

    def jks_path
      # Make the path a combination of the cog id and a hash of the jks data.
      jks_hash = Digest::MD5.hexdigest(jks.to_s)
      File.join Rails.root, 'tmp', "ipaws_#{cog_id}_#{jks_hash}.jks"
    end

    def write_jks_file
      path = jks_path
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, 'wb') { |f| f.write(jks) } unless File.exists?(path)
    end

  end
end