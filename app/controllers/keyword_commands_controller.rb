class KeywordCommandsController < ApplicationController
  wrap_parameters :command, include: [:params, :name, :command_type], format: [:json, :url_encoded_form]

  before_filter :find_user, :find_keyword
  before_filter :find_command, only: [:show, :update, :destroy]
  before_filter :set_page, only: :index

  def index
    @commands = @keyword.commands.page(@page)
    set_link_header(@commands)
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
    @keyword = special_keyword || @account.keywords.find(params[:keyword_id])
  end

  def special_keyword
    name = %w(stop start help default).find { |k| k == params[:keyword_id] }
    @account.keywords.where(name: name).first
  end

  def find_command
    @command = @keyword.commands.find(params[:id])
  end
end
