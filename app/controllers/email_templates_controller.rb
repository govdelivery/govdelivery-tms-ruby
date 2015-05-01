class EmailTemplatesController < ApplicationController
  before_action :find_user
  before_action :set_page, only: :index

  wrap_parameters EmailTemplate, format: [:json, :url_encoded_form]

  def index
    respond_with(@email_templates = account_templates.page(@page))
  end

  def show
    respond_with(@email_template = find_email_template)
  end

  def create
    @email_template = account_templates.create(template_params)
    respond_with @email_template
  end

  def update
    @email_template = find_email_template
    @email_template.update_attributes(template_params)
    respond_with(@email_template)
  end

  def destroy
    find_email_template.destroy
    render nothing: true, status: 204
  end

  private

  def template_params
    params[:email_template].except!(:from_address_id)
    transform_links_payload!(params[:email_template])
    params[:email_template].reverse_merge(from_address_id: @account.default_from_address.id)
  end

  def account_templates
    current_user.email_templates
  end

  def find_email_template
    account_templates.find(params[:id])
  end
end
