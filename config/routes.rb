Rails.application.routes.draw do
  root to: 'parkings#index'

  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords',
    ulocks: 'usres/unlocks',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  resources :parkings, only: [:index]

  resources :bookings, only: [:index, :new, :create, :destroy] do
    member do
      get :confirm_destroy
      get :confirm_release
      get :release
    end
  end

  post "/slack/command", to: "slack/commands#create"
end
