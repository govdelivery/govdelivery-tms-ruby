Tsms::Application.routes.draw do
  devise_for :users, :skip => :all
  
  resources :messages, :only => [:create, :show], :defaults => { :format => 'json' }
  
  get 'load_balancer' => 'load_balancer#show'
end
