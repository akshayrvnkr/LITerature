Rails.application.routes.draw do
  resources :game_user_movements
  resources :game_users
  resources :games do
    member do
      get :refresh
      get :status
      post :request_card
    end
  end
  resources :groups do
    member do
      get :new_game
    end
  end
  get 'pages/dashboard'
  devise_scope :user do
    unauthenticated :user do
      get '/' => "devise/sessions#new"
    end
  end
  devise_for :users
  authenticated :user do
    root :to => "pages#dashboard", :as => "dashboard"
  end
  unauthenticated :user do
    root :to => "devise/sessions#new"
  end

end
