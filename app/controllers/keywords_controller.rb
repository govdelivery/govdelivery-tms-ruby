class KeywordsController < ApplicationController
  include FeatureChecker
  wrap_parameters :keyword, :include => [:name, :response_text], :format => :json
  before_filter :find_user
  before_filter :find_keyword, :only => [:show, :update, :destroy]
  feature :sms

  def index
    @keywords = @account.keywords.custom
  end

  def show
  end

  def create
    @keyword = @account.keywords.new(params[:keyword])
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
    @keyword = @account.keywords.custom.find(params[:id])
  end
end
