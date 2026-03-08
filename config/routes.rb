# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # --- Auth (Devise) ---
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }, skip: [ :registrations ]

  devise_scope :user do
    get "users/sign_up", to: redirect("/users/sign_in")
  end

  authenticate :user do
    mount Sidekiq::Web => "/sidekiq"
  end

  authenticated :user do
    root "dashboards#show", as: :authenticated_root
  end

  unauthenticated do
    root "pages#installation"
  end

  # --- App ---
  resources :documents, only: [ :index, :new, :create, :show, :destroy ]

  resources :integrations, only: [ :index ] do
    delete "slack", to: "integrations#destroy_slack", on: :collection, as: :disconnect_slack
  end

  get "ask", to: "qa#new", as: :ask
  post "ask", to: "qa#create"
  get "dashboard", to: "dashboards#show", as: :dashboard
  get "team", to: "employees#index", as: :team
  post "team/:id/make_admin", to: "employees#make_admin", as: :make_admin_team_member

  # --- Slack ---
  namespace :slack do
    get  "/install",        to: redirect("/installation")
    get  "/connect",        to: "oauth#connect"
    get  "/oauth/callback", to: "oauth#callback"
    post "/events",         to: "events#receive"
  end

  # --- Public pages (Slack marketplace) ---
  get "installation", to: "pages#installation"
  get "privacy",      to: "pages#privacy"
  get "support",      to: "pages#support"
  get "terms",        to: "pages#terms"
end
