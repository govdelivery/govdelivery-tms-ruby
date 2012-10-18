Tsms::Application.routes.draw do

  resources :messages, :only => [:create, :show]

end
