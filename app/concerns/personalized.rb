module Personalized
  extend ActiveSupport::Concern

  included do
    serialize :macros
    attr_accessible :macros
    attr_readonly :macros
    validate :valid_macros
  end

  ##
  # Translate [[GD3_STYLE_MACROS]] to ##SM_STYLE_MACROS##
  #
  # @param attribute [Symbol] the field on this class to translate
  #
  def to_odm(attribute)
    send(attribute).gsub(/(\[\[)|(\]\])/, '##')
  end

  def valid_macros
    errors.add(:macros, 'must be a hash or null') unless try(:macros).nil? || macros.is_a?(Hash)
  end
end
