class TemplatesController < ApplicationController
  before_action :find_user

  def index
    respond_with(@templates = account_templates.page(@page))
  end

  def show
    respond_with(@template = find_template)
  end

  def create
    @template = account_templates.create(template_params)
    respond_with @template
  end

  def update
    @template = find_template
    @template.update_attributes(template_params)
    respond_with @template
  end

  def destroy
    find_template.destroy
    render nothing: true, status: 204
  end

  private

  def find_template
    account_templates.find_by(uuid: params[:uuid]) || raise(ActiveRecord::RecordNotFound)
  end
end
