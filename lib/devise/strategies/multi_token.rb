module Devise
  module Strategies
    class MultiToken < Devise::Strategies::Base
      def valid?
        !params[:auth_token].blank?
      end

      def authenticate!
        if user = User.with_token(params[:auth_token])
          success!(user)
        else
          fail(:invalid_token)
        end
      end
    end

    Warden::Strategies.add(:multi_token, Devise::Strategies::MultiToken)
  end
end
