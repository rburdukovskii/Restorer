Rails.application.routes.draw do
  devise_for :users

  root "home#index"

  resources :uploads, only: [:new, :create, :show] do
    member do
      get :status
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
