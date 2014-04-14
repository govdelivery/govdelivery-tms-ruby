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
      client.postCAP(attributes.as_json)
    end

    def client(reload=false)
      @client = nil if reload
      @client ||= begin
        write_jks_file
        IPAWSClient.new(cog_id, user_id, jks_path, public_password, private_password)
      end
    end

    private

    def jks_path
      # Make the path a combination of the cog id and a hash of the jks data.
      jks_hash = Digest::MD5.hexdigest(jks)
      File.join Rails.root, 'tmp', "ipaws_#{cog_id}_#{jks_hash}.jks"
    end

    def write_jks_file
      path = jks_path
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, 'wb') { |f| f.write(jks) } unless File.exists?(path)
    end

  end
end