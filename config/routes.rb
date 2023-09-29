Rails.application.routes.draw do
  resources :rounds
  resources :players
  resources :games

  root 'home#index'
end
