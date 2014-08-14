class WebhooksController < ApplicationController
  before_filter :find_user
  before_filter :find_webhook, except: [:index, :create]
  wrap_parameters :webhooks, include: [:url, :event_type], format: :json

  def index
    @webhooks = @account.webhooks.page(params[:page])
    respond_with(@webhooks)
  end

  def create
    respond_with(@webhook = @account.webhooks.create(params[:webhook]))
  end

  def update
    @webhook.update_attributes(params[:webhook])
    respond_with(@webhook)
  end

  def destroy
    @webhook.destroy
    render status: 204, nothing: true
  end

  protected

  def find_webhook
    @webhook = @account.webhooks.find(params[:id])
  end
end
