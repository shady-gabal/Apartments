Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'auth'
      get '/dashboard' => 'dashboard#index'
      resources :apartments, only: [:update, :delete, :create]
      resources :users, only: [:update, :delete, :create]
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
