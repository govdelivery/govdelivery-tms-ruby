module Personalized
  extend ActiveSupport::Concern

  included do
    serialize :macros, Hash
    attr_accessible :macros
  end
end