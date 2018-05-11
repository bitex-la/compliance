Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self) rescue ActiveAdmin::DatabaseHitDuringLoad

  # Concern must go first!
  namespace :api do
    resources :observation_reasons, only: [:show, :index]
    resources :people, only: [:create, :show, :index, :update] do
      resources :issues, only: [:create, :show, :index, :update] do
        resource :natural_docket_seed, only: %w(index create update)
        %i(
          domicile_seeds
          allowance_seeds
          identification_seeds
          phone_seeds
          email_seeds
          note_seeds
          affinity_seeds
        ).each do |entities|
          resources entities, only: [:show, :index, :create, :update]
        end
      end
    end
  end
end
