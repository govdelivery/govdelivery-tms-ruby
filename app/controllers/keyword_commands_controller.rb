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
    respond_with(@command = @keyword.create_command(params[:command]))
  end

  def update
    @command.update_attributes(params[:command])
    respond_with(@command)
  end

  def destroy
    @command.destroy
    render status: 204, nothing: true
  end

  private

  def find_keyword
    @keyword = special_keyword || default_keyword || @account.keywords.find(params[:keyword_id])
  end

  # shouldn't this handle stop, stopall, unsubscribe, cancel, end, quit, start, yes, help, and info a la keyword.rb?
  def special_keyword
    name = ['stop', 'help'].select { |k| k == params[:keyword_id] }.first
    Keywords.const_get(name.camelize).new(@account) if name
  end

  def default_keyword
    @account.default_keyword if params[:keyword_id] == 'default'
  end

  def find_command
    @command = @keyword.commands.find(params[:id])
  end


end
