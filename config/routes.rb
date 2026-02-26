require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users

  authenticate :user do
    mount Sidekiq::Web => "/sidekiq"
  end

  root "qa#new"

  resources :documents, only: [ :index, :new, :create, :show, :destroy ]

  get "ask", to: "qa#new"
  post "ask", to: "qa#create"
end
