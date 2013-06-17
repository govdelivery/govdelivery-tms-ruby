module Devise
  module Models
    module MultiTokenAuthenticatable
      extend ActiveSupport::Concern

      # There are no required fields for this concern, but the 
      # has_many relation needs a field named :token
      def self.required_fields(klass)
        []
      end

      # Build an authentication token record if 
      # there are zero. 
      def ensure_authentication_token
        if authentication_tokens.count < 1
          build_authentication_token
        end
      end

      def build_authentication_token
        authentication_tokens.build.tap do |t|
          t.token = self.class.authentication_token
        end
      end

      module ClassMethods

        # Generate a token checking if one does not already exist in the database.
        def authentication_token
          generate_token
        end

        # Generate a token by looping and ensuring does not already exist.
        def generate_token
          loop do
            # Devise.friendly_token is hard-coded to pass 15 to SecureRandom, 
            # resulting in a token that is 20 chars in length.  We want
            # 32 chars, so we pass in 24 directly to SecureRandom
            token = SecureRandom.base64(24).tr('+/=lIO0', 'pqrsxyz')
            break token unless AuthenticationToken.where(token: token).count > 0
          end
        end

        Devise::Models.config(self)
      end
    end
  end
end
