module IPAWS
  class Vendor < ActiveRecord::Base
    java_import com.govdelivery.ipaws.IPAWSClient if defined?(JRUBY_VERSION)

    self.table_name = 'ipaws_vendors'

    has_many :accounts, foreign_key: :ipaws_vendor_id, inverse_of: :ipaws_vendor

    validates :cog_id, :user_id, :public_password_encrypted, :private_password_encrypted, :jks, presence: true

    attr_accessible
    attr_encrypted :public_password, attribute: :public_password_encrypted
    attr_encrypted :private_password, attribute: :private_password_encrypted

    def ack
      client.getAck.as_json.first || {}
    end

    def cog_profile
      # Flatten parameter list into a single hash.
      client.getCOGProfile.as_json.reduce({}) do |profile, item|
        if item.key?('eventCodes')
          profile['eventCodes'] = item['subParaListItem']
        elsif item.key?('geoCodes')
          profile['geoCodes'] = item['subParaListItem']
        else
          profile.merge!(item)
        end
        profile
      end
    end

    def post_alert(attributes)
      # postCAP needs the attributes "sanitized" with as_json to remove symbols.
      # The response statuses will be grouped in groups of 4 and merged together.
      reform_cap_response(client.postCAP(attributes.as_json)).reduce({}) do |response, item|
        # If the item only has subParaListItem, this is our list of statuses.
        response['statuses'] ||= []
        if item.keys == ['subParaListItem']
          response['statuses'] += item['subParaListItem'].in_groups_of(4, false).map { |hashes| hashes.inject(&:merge!)}
        else
          response.merge!(item)
        end
        response
      end
    end

    def nwem_cog_authorization
      client.isCogAuthorized.as_json.first || {}
    end

    def nwem_areas
      # Combines attributes in subParaListItem with root item and flattens into a single hash.
      client.getNWEMAuxData.as_json.map do |item|
        if sub_items = item.delete('subParaListItem')
          item.merge! sub_items.reduce(&:merge!)
        end
        item
      end
    end

    def client(reload=false)
      @client = nil if reload
      @client ||= begin
        write_jks_file
        IPAWSClient.new(cog_id, user_id, jks_path, public_password, private_password, Rails.configuration.fema_url)
      end
    end

    private

    def reform_cap_response(cap_response)
      # The CAP response provided by FEMA is in a strange format:
      # 1. The response attributes are not structurally grouped.
      # 2. The response attributes are not themselves under any sort of key (empty string).
      cap_response = cap_response.as_json
      if responses = cap_response.delete('')
        cap_response['responses'] = responses.in_groups_of(4, false).map do |group|
          group.inject { |response, attributes| response.merge(attributes)}
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
      File.open(path, 'wb') { |f| f.write(jks)} unless File.exist?(path)
    end
  end
end
