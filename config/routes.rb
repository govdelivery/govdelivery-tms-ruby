Tsms::Application.routes.draw do
  devise_for :users, :skip => :all

  resources(:messages, :only => [:index, :new, :create, :show], :defaults => {:format => 'json'}) do
    collection do
      get 'page/:page' => "messages#index", :as => :paged
    end
  end

  resources :services, :only => :index, :defaults => {:format => 'json'}
  root :to => 'services#index'
  get 'load_balancer' => 'load_balancer#show'
end
