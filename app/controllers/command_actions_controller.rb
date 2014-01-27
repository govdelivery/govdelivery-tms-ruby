class CommandActionsController < ApplicationController
  before_filter :find_parent

  def index
    respond_with(@command_actions = finder.page(@page))
  end

  def show
    respond_with(@command_action = finder.find(params[:id]))
  end

  protected

  def finder
    @parent.command_actions.includes(command: {event_handler: :keyword})
  end

  def find_parent
    @parent = if params[:sms_id]
                current_user.sms_vendor.inbound_messages.find(params[:sms_id])
              elsif params[:command_id]
                current_user.account.commands.where(id: params[:command_id]).first
              end
  end

end