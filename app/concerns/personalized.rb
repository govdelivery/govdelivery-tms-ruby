module Personalized
  extend ActiveSupport::Concern

  included do
    serialize :macros, Hash
    attr_accessible :macros
  end

  ##
  # Translate [[GD3_STYLE_MACROS]] to ##SM_STYLE_MACROS##
  #
  # @param attribute [Symbol] the field on this class to translate
  #
  def to_odm(attribute)
    self.send(attribute).gsub(/(\[\[)|(\]\])/,'##')
  end
end