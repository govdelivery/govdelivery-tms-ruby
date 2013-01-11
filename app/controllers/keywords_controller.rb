class KeywordsController < ApplicationController
  before_filter :find_user
  before_filter :find_keyword, :only => [:show, :update, :destroy]

  def index
    @keywords = @account.keywords
  end

  def show
  end

  def create
    @keyword = @account.keywords.new(params[:keyword])
    @keyword.vendor = @account.sms_vendor
    @keyword.save
    respond_with(@keyword)
  end

  def update
    @keyword.update_attributes(params[:keyword])
    respond_with(@keyword)
  end

  def destroy
    @keyword.destroy
  end

  private
  def find_keyword
    @keyword = @account.keywords.find(params[:id])
  end
end