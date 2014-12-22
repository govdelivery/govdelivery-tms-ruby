class KeywordsController < ApplicationController
  include FeatureChecker
  wrap_parameters :keyword, include: [:name, :response_text], format: [:json, :url_encoded_form]
  before_filter :find_user
  before_filter :find_keyword, :only => [:show, :update]
  feature :sms

  def index
    @keywords = @account.keywords
  end

  def show
  end

  def create
    @keyword = @account.keywords.new(params[:keyword])
    @keyword.save
    respond_with(@keyword)
  end

  def update
    params[:keyword].delete(:name) if ['stop', 'start', 'help', 'default'].include?(params[:keyword] && params[:keyword].try(:[], :name))
    @keyword.update_attributes(params[:keyword])
    respond_with(@keyword)
  end

  def destroy
    @keyword = @account.keywords.custom.find(params[:id])
    @keyword.destroy
  end

  private

  def find_keyword
    @keyword = @account.keywords.find(params[:id])
  end
end
