Rails.application.routes.draw do
  resources :users

  # https://github.com/presidentbeef/brakeman/issues/1410
  x = ->(args) {
  }

  match "/login/oauth/authorize",
  :to => "users#login",
  :via => [:get, :post]
end
