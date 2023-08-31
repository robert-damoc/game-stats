Rails.application.routes.draw do
  resources :players
  resources :games do
    member do
      put 'start_game', to: 'games#start_game'
      put 'complete_game', to: 'games#complete_game'
      put 'cancel_game', to: 'games#cancel_game'
    end
  end

  root 'home#index'
end
