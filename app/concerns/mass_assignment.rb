# If we were using Rails 4, we'd use ActiveModel::Model instead
module MassAssignment
  def assign!(params)
    params.each do |key, value|
      self.public_send("#{key}=", value)
    end
  end

  def initialize(opts={})
    assign!(opts)
  end
end