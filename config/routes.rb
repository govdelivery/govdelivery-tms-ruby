Tsms::Application.routes.draw do

  require 'sidekiq/web'
  constraint = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin? }
  constraints constraint do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :inbound_messages, except: :edit

  devise_for :users, :skip => :all

  # call this to add pagination to your controller
  # e.g.
  # pageable('messages') =>
  # paged_messages GET    /messages/page/:page(.:format)                        messages#index
  def pageable(controller)
    collection do
      get 'page/:page' => "#{controller}#index", :as => :paged
    end
  end

  resources(:emails, :only => :create)

  resources(:messages, :only => [:index, :new, :create, :show]) do
    pageable('messages')
    resources(:recipients, :only => [:index, :show]) do
      pageable('recipients')
    end
  end

  resources(:inbound_messages, :only => [:index, :show]) do
    pageable('inbound_messages')
  end

  root :to => 'services#index'
  get 'load_balancer' => 'load_balancer#show'
  post 'twilio_requests' => 'twilio_requests#create'
  post 'twilio_status_callbacks' => 'twilio_status_callbacks#create'
  post 'twiml' => 'twilio_dial_plan#show', :defaults => {:format => 'xml'}
end
