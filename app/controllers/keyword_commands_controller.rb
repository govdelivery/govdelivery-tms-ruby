class KeywordCommandsController < ApplicationController
  before_filter :find_user, :find_keyword
  before_filter :find_command, :only => [:show, :update]
  before_filter :parse_command_parameters, :only => [:create, :update]

  def index
    @commands = @keyword.commands
  end

  def show
  end

  def create
    @command = @keyword.commands.new(params[:command]).tap{|c| c.account = @account }
    @command.save
    respond_with(@command)
  end

  def update
    @command.update_attributes(params[:command])
    respond_with(@command)
  end

  private
  def find_keyword
    @keyword = @account.keywords.find(params[:keyword_id])
  end

  def find_command
    @command = @keyword.commands.find(params[:id])
  end

  def parse_command_parameters
    if params[:command] && params[:command][:params]
      params[:command][:params] = CommandParameters.new(params[:command][:params])
    end
  end
end
