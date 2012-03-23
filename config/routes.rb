Sauron::Application.routes.draw do
  root to: "messages#index"

  if Rails.env.test?
    # So that we can test arbitrary test controllers but avoid exposing this catch-all route in production
    match ':controller(/:action(/:id))'
  end
end
