class KeywordsController < ApplicationController
  before_filter :find_user

  def index
    @keywords = @account.keywords
  end

  def show
    @keyword = @account.keywords.find(params[:id])
  end
end
