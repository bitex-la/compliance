# frozen_string_literal: true
module Abilities
  class Security
    include CanCan::Ability

    def initialize(user)
      can :read, [AdminUser]
      
      can :update, AdminUser

      can :create, AdminUser

      can :enable_otp, user
      can :view_index, AdminUser
      can :disable_otp, AdminUser
      can :full_update, AdminUser
      can :full_read, AdminUser
    end
  end
end
