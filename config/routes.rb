Rails.application.routes.draw do
  resources :players
  resources :games do
    resources :rounds, only: %i[new create edit update destroy]
  end

  root 'home#index'
end
