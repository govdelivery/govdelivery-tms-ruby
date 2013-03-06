# If we were using Rails 4, we'd use ActiveModel::Model instead
module MassAssignment
  extend ActiveSupport::Concern
  
  module ClassMethods
    def attr_accessible(*args)
      accessible_attributes.concat(args.map(&:to_sym))
    end  

    def accessible_attributes
      @attributes ||= []
    end
  end


  def assign!(params)
    params.each do |key, value|
      self.public_send("#{key}=", value) if self.class.accessible_attributes.include?(key.to_sym)
    end
  end

  def initialize(opts={})
    assign!(opts)
  end
end