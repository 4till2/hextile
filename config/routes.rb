Rails.application.routes.draw do
  devise_for :admins, controllers: { omniauth_callbacks: 'admins/omniauth_callbacks' }

  # Defines the root path route ("/")
  root "home#index"
  get 'map', to: 'maps#json'
  get 'maps', to: 'maps#index', as: 'maps'
  post 'subscribe', to: 'subscriptions#subscribe', as: 'subscribe'
  get 'unsubscribe', to: 'subscriptions#unsubscribe', as: 'unsubscribe'
  get 'confirm', to: 'subscriptions#confirm', as: 'confirm'
  namespace 'admins' do
    get 'reset-waypoints', to: 'switchboard#reset_waypoints'
    get 'reset-cache', to: 'switchboard#reset_cache'
    get 'reset-all', to: 'switchboard#reset_all'
    get 'login', to: 'switchboard#login'
  end
end
