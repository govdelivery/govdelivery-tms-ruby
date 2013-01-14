class KeywordActionsController < ApplicationController
  before_filter :find_user, :find_keyword
    
  def index
    @actions = @keyword.actions
  end

  def show
    @action = @keyword.actions.find(params[:id])
  end

  def create
    @action = @keyword.actions.new(params[:action])
    @action.account = @account
    @action.save
    @action
  end

  private
  def find_keyword
    @keyword = @account.keywords.find(params[:keyword_id])
  end
end
