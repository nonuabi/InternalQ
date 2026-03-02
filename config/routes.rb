require "sidekiq/web"

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  authenticate :user do
    mount Sidekiq::Web => "/sidekiq"
  end

  root "qa#new"



  resources :documents, only: [ :index, :new, :create, :show, :destroy ]

  resources :integrations, only: [ :index ] do
    delete "slack", to: "integrations#destroy_slack", on: :collection, as: :disconnect_slack
  end


  get "ask", to: "qa#new", as: :ask
  post "ask", to: "qa#create"

  # Slack integration
  namespace :slack do
    get  "/install",        to: redirect("/installation")  # Direct Install URL = /installation (sign up first)
    get  "/connect",        to: "oauth#connect"
    get  "/oauth/callback", to: "oauth#callback"
    post "/events",         to: "events#receive"
  end

  # Public pages for Slack marketplace (installation landing, privacy, support, terms)
  get "installation", to: "pages#installation"
  get "privacy",       to: "pages#privacy"
  get "support",       to: "pages#support"
  get "terms",         to: "pages#terms"

  get "team", to: "employees#index", as: :team
  post "team/:id/make_admin", to: "employees#make_admin", as: :make_admin_team_member
end
