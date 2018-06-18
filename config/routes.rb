Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self) rescue ActiveAdmin::DatabaseHitDuringLoad

  # Concern must go first!
  namespace :api do
    resources :observation_reasons, only: [:show, :index]
    resources :event_logs, only: [:show, :index]
    resources :people, only: [:create, :show, :index, :update] do
      %i(
        natural_dockets
        legal_entity_dockets
        argentina_invoicing_details
        chile_invoicing_details
        domiciles
        allowances
        identifications
        phones
        emails
        notes
        affinities
      ).each do |entities|
        resources entities, only: [:show, :index]
      end

      resources :issues, only: [:create, :show, :index, :update] do
        resources :observations, only: [:create, :show, :index, :update]
        %i(
          natural_docket_seeds
          legal_entity_docket_seeds
          argentina_invoicing_detail_seeds
          chile_invoicing_detail_seeds
          domicile_seeds
          allowance_seeds
          identification_seeds
          phone_seeds
          email_seeds
          note_seeds
          affinity_seeds
        ).each do |entities|
          resources entities, only: [:show, :index, :create, :update] do
            resources :attachments, only: [:create, :update, :show, :index]
          end
        end
      end
    end
  end
end
