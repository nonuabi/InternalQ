require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users
  
  authenticate :user do
    mount Sidekiq::Web => "/sidekiq"
  end

  resources :documents, only: [:index, :new, :create]
end
