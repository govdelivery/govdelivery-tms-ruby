Xact::Application.routes.draw do

  require 'sidekiq/web'
  require 'sidekiq/pro/web'
  constraint = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin? }
  constraints constraint do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, :skip => :all, :token_authentication_key => 'auth_token'

  # call this to add pagination to your controller
  # e.g.
  # pageable =>
  # paged_messages GET    /messages/page/:page(.:format)                        messages#index
  def pageable
    get 'page/:page', :action => :index, :on => :collection
  end

  resources(:accounts, only: []) do
    resources(:users, only: []) do
      resources(:tokens, only: [:index, :create, :show, :destroy]) do
        pageable
      end
    end
  end

  resources(:keywords, :only => [:index, :show, :create, :update, :destroy]) do
    resources(:commands, :only => [:index, :show, :create, :update, :destroy], :controller => :keyword_commands) do
      pageable
      resources :actions, only: [:index, :show], controller: :command_actions
    end
  end

  scope :messages, :path => 'messages' do
    resources(:email, :only => [:index, :new, :create, :show], :controller => :email_messages) do
      pageable
      resources(:recipients, :only => [:index, :show]) do
        pageable
        collection do
          get :clicked
          get :opened
        end
        resources(:opens, only: [:index, :show]) do
          pageable
        end
        resources(:clicks, only: [:index, :show]) do
          pageable
        end
      end
    end
    {:sms => :sms_messages, :voice => :voice_messages}.each do |_resource, _controller|
      resources(_resource, :only => [:index, :new, :create, :show], :controller => _controller) do
        pageable
        resources(:recipients, :only => [:index, :show]) do
          pageable
        end
      end
    end
  end

  scope :inbound, :path => 'inbound', :as => 'inbound' do
    resources(:sms, :only => [:index, :show], :controller => :inbound_messages) do
      pageable
      resources :command_actions, only: [:index, :show]
    end
  end

  namespace :ipaws do
    resources :event_codes, only: :index
    resources :categories, only: :index
    resources :response_types, only: :index
    resource :acknowledgement, only: :show
    resource :cog_profile, only: :show
  end

  root :to => 'services#index'
  get 'load_balancer' => 'load_balancer#show'
  get 'command_types' => 'command_types#index'
  post 'twilio_requests' => 'twilio_requests#create'
  post 'twilio_status_callbacks' => 'twilio_status_callbacks#create'
  post 'twiml' => 'twilio_dial_plan#show', :defaults => {:format => 'xml'}

  %w( 400 401 403 404 405 406 422 500).each do |code|
    get code, :to => "errors#show", :code => code
  end
end
