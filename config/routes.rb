Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Concern must go first!
  concern :api_base do
    resources :issues do
    end
    resources :people do
    end
    resources :domicile_seeds do
    end
  end

  namespace :api do  
    concerns :api_base
  end  
end
