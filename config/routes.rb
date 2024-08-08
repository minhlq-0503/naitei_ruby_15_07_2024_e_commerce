Rails.application.routes.draw do
  scope "(:locale)", locale: /vi|en/ do
    root "static_pages#home"
    get "static_pages/home"

    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"

    get "/signup", to: "users#new"
    post "/signup", to: "users#create"
    resources :users, only: %i(new create show)
  end
end
