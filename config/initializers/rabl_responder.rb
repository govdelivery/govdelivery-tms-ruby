class RablResponder < ActionController::Responder
  def to_format
    if post?
      controller.response.status = (resource.nil? || resource.new_record?) ? :unprocessable_entity : :created
    else
      super
    end
  end
end