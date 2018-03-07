Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self) rescue ActiveAdmin::DatabaseHitDuringLoad

  # Concern must go first!
  namespace :api do
    resources :people, only: [:create, :show, :index, :update] do
      resources :issues, only: [:create, :show, :index, :update]
    end
  end
end
