Rails.application.routes.draw do
  namespace :api do
    resources :people, only: [:create, :show, :index, :update]

    resources :issues, only: [:create, :show, :index, :update] do
      member do
        Issue.aasm.events.map(&:name).each do |action|
          post action
        end

        %i{
          lock_issue
          unlock_issue
          renew_lock
        }.each do |action|
          post action
        end
      end
    end

    %i(
      natural_dockets
      legal_entity_dockets
      risk_scores
      argentina_invoicing_details
      chile_invoicing_details
      domiciles
      allowances
      identifications
      phones
      emails
      notes
      affinities
      event_logs
    ).each do |entities|
      resources entities, only: [:show, :index]
    end

    %i(
      natural_docket_seeds
      legal_entity_docket_seeds
      risk_score_seeds
      argentina_invoicing_detail_seeds
      chile_invoicing_detail_seeds
      domicile_seeds
      allowance_seeds
      identification_seeds
      phone_seeds
      email_seeds
      note_seeds
      affinity_seeds
      tags
    ).each do |entities|
      resources entities, except: [:new, :edit]
    end

    %i(
      fund_deposits
      attachments
      observation_reasons
      observations
      workflows
    ).each do |entities|
      resources entities, only: [:show, :index, :create, :update]
    end

    %i(
      workflows
      tasks
    ).each do |entities|
      resources entities, except: [:new, :edit] do
        member do
          entities.to_s.classify.constantize
            .aasm.events.map(&:name).each do |action|
              post action
            end
        end
      end
    end
    
    %i(
      person_taggings
      issue_taggings
    ).each do |entities|
      resources entities, except: [:new, :edit, :update]
    end

    resource :system do
      post :truncate
    end
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
  begin 
    ActiveAdmin.routes(self)
  rescue ActiveAdmin::DatabaseHitDuringLoad
    puts "Ignoring database hit during load"
  end
end
