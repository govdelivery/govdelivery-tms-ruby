module IPAWS
  class CategoriesController < IPAWS::Controller

    def index
      respond_with Category.all
    end
    
  end
end