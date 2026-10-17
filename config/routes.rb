Rails.application.routes.draw do
  devise_for :users

  root "home#index"

  resource :profile, only: [:show, :edit, :update]

  get "gallery", to: "gallery#index", as: :gallery

  resources :uploads, only: [:new, :create, :show, :update, :destroy] do
    member do
      get :status
      patch :toggle_favorite
      get :download
      get   :add_to_album
      post  :assign_to_album
      post   :add_tag
      delete :remove_tag
    end

    collection do
      delete :bulk_destroy
      post   :bulk_add_to_album 
    end
  end

  resources :albums, only: [:new, :create, :show, :edit, :update, :destroy] do
    member do
      post :add_upload
      delete :remove_upload
      post   :bulk_add_uploads
    end
  end

  resources :tags, only: [:index, :create, :destroy] do
    member do
      get :photos
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
