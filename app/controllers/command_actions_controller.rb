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
    @parent.command_actions.includes(command: [:keyword])
  end

  def find_parent
    @parent = if params[:sms_id]
                current_user.sms_vendor.inbound_messages.
                  where(id: params[:sms_id], account_id: current_user.account.id).first!
              elsif params[:command_id]
                current_user.account.commands.where(id: params[:command_id]).first!
              end
  end

end
