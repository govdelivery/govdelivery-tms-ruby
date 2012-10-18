Tsms::Application.routes.draw do

  resources :messages, :only => [:create, :show], :defaults => { :format => 'json' }
  
  get 'load_balancer' => 'load_balancer#show'
end
