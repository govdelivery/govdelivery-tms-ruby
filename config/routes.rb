
Tsms::Application.routes.draw do
  require 'sidekiq/web'
  constraint = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin? }
  constraints constraint do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :inbound_messages, except: :edit

  devise_for :users, :skip => :all

  resources(:messages, :only => [:index, :new, :create, :show]) do
    collection do
      get 'page/:page' => "messages#index", :as => :paged
    end
  end

  resources(:inbound_messages, :only => [:index, :show]) do
      collection do
        get 'page/:page' => "inbound_messages#index", :as => :paged
      end
    end

  root :to => 'services#index'
  get 'load_balancer' => 'load_balancer#show'
  post 'twilio_requests' => 'twilio_requests#create'
end
