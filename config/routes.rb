Rails.application.routes.draw do
  resource :game, only: [:new]
  root 'root#index'
end
