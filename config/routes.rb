Rails.application.routes.draw do
  resources :players
  resources :games

  root 'home#index'
end
