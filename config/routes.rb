Rails.application.routes.draw do
  # For details on the DSL available within this file, see
  # https://guides.rubyonrails.org/routing.html
  root 'home#index'

  get 'sign-in', to: 'sessions#new', as: :new_session
  resource :session, only: %i[show create destroy]
end
