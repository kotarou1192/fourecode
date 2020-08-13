# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace 'api' do
    namespace 'v1' do
      resources :users, only: %i[show create destroy update]
      put '/account_activations', to: 'account_activations#update'
      post '/auth', to: 'auth#create'
      delete '/auth', to: 'auth#destroy'
      put '/auth', to: 'auth#update'
      get '/auth', to: 'auth#index'
    end
  end
end
