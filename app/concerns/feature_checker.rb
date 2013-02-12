module FeatureChecker
  extend ActiveSupport::Concern

  included do
    # This check needs to happen after the @account is defined
    def check_if_feature_is_enabled
      unless self.class.features.blank? || self.class.features.all?{|f| @account.feature_enabled?(f) }
        render :json => {:errors => ["This feature is not enabled on your account.  Please contact GovDelivery for further assistance."]}, :status => :forbidden
      end
    end
  end

  module ClassMethods
    #
    # Indicate that this controller is protected by the specified 'feature flag.'  The
    # checker will call "#{feature}_enabled?" on the current account, so it is necessary
    # for this code to be invoked *after* the before_filter to load a user's account.
    # 
    # === Example
    #
    #   include FeatureChecker
    #   feature :sms
    #
    def feature(feat)
      before_filter :check_if_feature_is_enabled if features.length == 0
      features << feat unless features.include?(feat)
    end
    
    def features
      @features ||= []
    end
  end
end