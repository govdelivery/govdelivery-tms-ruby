module IPAWS
  class CategoriesController < ApplicationController

    include FeatureChecker
    
    before_filter :find_user
    feature :ipaws

    def index
      respond_with Category.all
    end
    
  end
end