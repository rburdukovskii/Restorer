Rails.application.routes.draw do
  devise_for :users

  root "home#index"

  resource :profile, only: [:show, :edit, :update]

  get "gallery", to: "gallery#index", as: :gallery

  resources :uploads, only: [:new, :create, :show] do
    member do
      get :status
      patch :toggle_favorite
      get :download
    end
  end

  resources :albums, only: [:new, :create, :show, :edit, :update, :destroy] do
    member do
      post :add_upload
      delete :remove_upload
    end
  end

  resources :tags, only: [:index, :create, :destroy]

  get "up" => "rails/health#show", as: :rails_health_check
end
