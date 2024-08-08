Rails.application.routes.draw do
  scope "(:locale)", locale: /vi|en/ do
    # root to: "static_pages/home"
    root "static_pages#home"
    get "static_pages/home"
  end
end
