Rails.application.routes.draw do
  resource :game, only: [:new, :update]
  root 'root#index'
end
