# frozen_string_literal: true

Rails.application.routes.draw do
  root 'top#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  delete '/logout', to: 'sessions#destroy'
  get '/auth/stid', to: 'sessions#new'
  get '/auth/callback', to: 'omniauth_callbacks#callback'
  get '/auth/failure', to: 'omniauth_callbacks#failure'
end
