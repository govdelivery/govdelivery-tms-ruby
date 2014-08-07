module SimpleTokenAuthentication
  module ActsAsMultiTokenAuthenticatable
    extend ActiveSupport::Concern

    # Please see https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
    # before editing this file, the discussion is very interesting.

    included do
      private :multi_generate_authentication_token
    end

    # Build an authentication token record if
    # there are zero.
    def ensure_authentication_token
      if authentication_tokens.count < 1
        multi_generate_authentication_token
      end
    end

    def multi_generate_authentication_token
      authentication_tokens.build.tap do |t|
        t.token = generate_token
      end
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

    module ClassMethods
      def acts_as_multi_token_authenticatable(options = {})
        include SimpleTokenAuthentication::ActsAsMultiTokenAuthenticatable
        before_save :ensure_authentication_token
      end
    end
  end
end
ActiveRecord::Base.send :include, SimpleTokenAuthentication::ActsAsMultiTokenAuthenticatable
