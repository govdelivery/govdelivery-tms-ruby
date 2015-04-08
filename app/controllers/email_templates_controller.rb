class EmailTemplatesController < ApplicationController
  before_filter :find_user
  before_filter :set_page, only: :index

  def index
    respond_with(@email_templates = account_templates.page(@page))
  end

  def show
    respond_with(@email_template = find_email_template)
  end

  def create
    params.except!(:from_address_id)
    transform_links_payload!
    template_params = params.reverse_merge(from_address_id: @account.default_from_address.id)
    @email_template = account_templates.create(template_params) do |template|
      template.user = current_user
    end
    respond_with @email_template
  end

  def update
    params.except!(:from_address_id)
    transform_links_payload!
    @email_template = find_email_template
    @email_template.update_attributes(params)
    respond_with(@email_template)
  end

  def destroy
    find_email_template.destroy
    render nothing: true, status: 204
  end

  private

  def account_templates
    @account.email_templates
  end

  def find_email_template
    account_templates.find(params[:id])
  end
end
