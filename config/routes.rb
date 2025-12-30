# frozen_string_literal: true

Rails.application.routes.draw do
  # TODO: Improve this as /learnings should be the same as doing /learnings/index, so we may not need the explicit '/index'
  devise_for :users

  devise_scope :user do
    root 'devise/sessions#new'
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker
  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"

  post 'sign_up', to: 'users#create'

  resource :profile, only: %i[show update],
                     controller: 'users'

  resources :feed, only: [:index]

  resources :learnings do
    member do
      get :cancel
    end
  end
end
