# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace 'api' do
    namespace 'v1' do
      resources :users, only: %i[show create destroy update]
      resources :posts, only: %i[show create destroy update]
      put '/account_activations', to: 'account_activations#update'
      post '/auth', to: 'auth#create'
      delete '/auth', to: 'auth#destroy'
      put '/auth', to: 'auth#update'
      get '/auth', to: 'auth#index'
      post '/password_resets', to: 'password_resets#create'
      put '/password_resets', to: 'password_resets#update'
      get '/search/posts', to: 'posts_searches#search'
      get '/search/users', to: 'users_searches#search'

      # routing for reviews and responses
      get '/posts/:id/reviews', to: 'reviews#show'
      post '/posts/:id/reviews', to: 'reviews#create'
      post '/posts/:id/reviews/:review_id', to: 'responses#create'
    end
  end
end
