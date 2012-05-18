Sauron::Application.routes.draw do
  root to: "messages#index"
  resources :messages, only: [:show] do
    collection do
      get :search
    end
  end
  resources :conversations, only: [:index, :show]
  resource :ping, only: [:show]

  if Rails.env.test?
    # So that we can test arbitrary test controllers but avoid exposing this catch-all route in production
    match ':controller(/:action(/:id))'
  end
end
