Tsms::Application.routes.draw do
  devise_for :users, :skip => :all

  resources(:messages, :only => [:index, :create, :show], :defaults => {:format => 'json'}) do
    collection do
      get 'page/:page' => "messages#index", :as => :paged
    end
  end


  get 'load_balancer' => 'load_balancer#show'
end
