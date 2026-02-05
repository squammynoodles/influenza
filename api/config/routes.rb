Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resource :session, only: [:create, :destroy]
      resources :users, only: [:create, :show]
      resource :password, only: [:create, :update]
      resources :invitations, only: [:create] do
        collection do
          get :verify
        end
      end
      resources :influencers do
        resources :youtube_channels, only: [:create, :destroy]
        resources :twitter_accounts, only: [:create, :destroy]
        resources :contents, only: [:index]
      end
    end
  end

  # Health check endpoint
  get "health", to: proc { [200, {}, ["OK"]] }

  # Rails built-in health check
  get "up" => "rails/health#show", as: :rails_health_check
end
