class EmailTemplatesController < TemplatesController

  wrap_parameters EmailTemplate, format: [:json, :url_encoded_form]

  private

  def template_params
    params[:email_template].except!(:from_address_id)
    transform_links_payload!(params[:email_template])
    params[:email_template].reverse_merge(from_address_id: @account.default_from_address.id)
  end

  def account_templates
    current_user.email_templates
  end
end
