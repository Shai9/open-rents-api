Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "health", to: "health#index"
      
      resources :neighborhoods, only: [:index, :show] do
      end
      
      post "users/request_verification", to: "users#request_verification"
      post "users/verify", to: "users#verify"
    end
  end
end