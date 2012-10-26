Tsms::Application.routes.draw do
  devise_for :users, :skip => :all

  resources(:messages, :only => [:index, :new, :create, :show]) do
    collection do
      get 'page/:page' => "messages#index", :as => :paged
    end
  end

  root :to => 'services#index'
  get 'load_balancer' => 'load_balancer#show'
end
