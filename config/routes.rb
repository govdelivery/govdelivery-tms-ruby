Tsms::Application.routes.draw do

  resources :messages, :only => [:create, :show]
  
  get 'load_balancer' => 'load_balancer#show'

end
