class KeywordCommandsController < ApplicationController
  wrap_parameters :command, :include => [:params, :name, :command_type], :format => :json

  before_filter :find_user, :find_keyword
  before_filter :find_command, :only => [:show, :update, :destroy]

  def index
    @commands = @keyword.commands
  end

  def show
  end

  def create
    @command = @keyword.commands.new(params[:command])
    @command.account = @account
    @command.save
    respond_with(@command)
  end

  def update
    @command.update_attributes(params[:command])
    respond_with(@command)
  end

  def destroy
    @command.destroy
  end

  private

  def find_keyword
    @keyword = @account.keywords.find(params[:keyword_id])
  end

  def find_command
    @command = @keyword.commands.find(params[:id])
  end


end
