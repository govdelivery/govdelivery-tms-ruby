class RablResponder < ActionController::Responder
  def to_format
    if post?
      controller.response.status = resource.new_record? ? :unprocessable_entity : :created
    elsif put?
      controller.response.status = resource.valid? ? :ok : :unprocessable_entity
    else
      super
    end
  end
end
