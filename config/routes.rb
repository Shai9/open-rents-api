Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "health", to: "health#index"
      
      get "database/status", to: "database#status"
      
      resources :neighborhoods, only: [:index, :show] do
        member do
          get :reports
          get :insights 
        end
      end
      
      resources :reports, only: [:index, :show, :create, :update, :destroy]
      
      post "users/request_verification", to: "users#request_verification"
      post "users/verify", to: "users#verify"
      post "users/login", to: "users#login" 
    end
  end
end