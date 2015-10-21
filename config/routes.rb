Xact::Application.routes.draw do
  require 'sidekiq/pro/web'

  constraint = ->(request) {request.env['warden'].authenticate? && request.env['warden'].user.admin?}
  constraints constraint do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, skip: :all

  root to: 'services#index'

  # call this to add pagination to your controller
  # e.g.
  # pageable
  #   paged_messages GET    /messages/page/:page(.:format)                        messages#index
  def pageable
    get 'page/:page', action: :index, on: :collection
  end

  resources(:accounts) do
    resources(:users, only: [:index]) do
      resources(:tokens, only: [:index, :create, :show, :destroy]) do
        pageable
      end
    end
  end

  resources(:from_addresses, only: [:index, :show]) do
    pageable
  end

  resources(:keywords) do
    pageable
    resources(:commands, controller: :keyword_commands) do
      pageable
      resources :actions, only: [:index, :show], controller: :command_actions
    end
  end

  resources(:incoming_voice_messages, only: [:index, :create, :show]) do
    pageable
  end

  scope :templates, path: 'templates', as: 'templates' do
    resources :email, except: [:new, :edit], controller: :email_templates do
      pageable
    end
    resources :sms, except: [:new, :edit], controller: :sms_templates do
      pageable
    end
  end

  scope :messages, path: 'messages' do
    resources(:email, only: [:index, :new, :create, :show], controller: :email_messages) do
      pageable
      resources(:recipients, only: [:index, :show]) do
        pageable
        collection do
          get :clicked
          get :opened
          get :failed
          get :sent
        end
        resources(:opens, only: [:index, :show]) do
          pageable
        end
        resources(:clicks, only: [:index, :show]) do
          pageable
        end
      end
    end
    {sms: :sms_messages}.each do |res, con|
      resources(res, only: [:index, :new, :create, :show], controller: con) do
        pageable
        resources(:recipients, only: [:index, :show]) do
          pageable
          collection do
            get :failed
            get :sent
          end
        end
      end
    end
    {voice: :voice_messages}.each do |res, con|
      resources(res, only: [:index, :new, :create, :show], controller: con) do
        pageable
        resources(:recipients, only: [:index, :show]) do
          pageable
          collection do
            get :failed
            get :sent
            get :busy
            get :human
            get :machine
            get :no_answer
            get :could_not_connect
          end
        end
      end
    end
  end

  scope :inbound, path: 'inbound', as: 'inbound' do
    resources(:sms, only: [:index, :show], controller: :inbound_messages) do
      pageable
      resources :command_actions, only: [:index, :show]
    end
  end

  namespace :ipaws do
    # Static Types
    resources :event_codes, only: :index
    resources :categories, only: :index
    resources :response_types, only: :index
    # Dynamic Endpoints
    resource :acknowledgement, only: :show
    resource :cog_profile, only: :show
    resource :nwem_authorization, only: :show
    resources :nwem_areas, only: :index
    resources :alerts, only: :create
  end

  get 'load_balancer' => 'load_balancer#show'
  get 'command_types' => 'command_types#index'
  post 'twilio_requests' => 'twilio_requests#create'
  post 'twilio_voice_requests' => 'twilio_voice_requests#create'
  post 'twilio_status_callbacks' => 'twilio_status_callbacks#create'
  post 'twiml' => 'twilio_dial_plan#show', defaults: {format: 'xml'}
  post 'mblox' => 'mblox#report'

  %w( 400 401 403 404 405 406 422 500).each do |code|
    get code, to: 'errors#show', code: code
  end

  resources :webhooks
end
