# frozen_string_literal: true

module Abilities
  class BusinessAdmin
    include CanCan::Ability

    def initialize(user)
      can :manage, :all
      cannot :manage, [EventLog]
      cannot :create, AdminUser
      cannot :update, AdminUser
      cannot :disable_user, AdminUser
      cannot :view_index, AdminUser

      can :read, user
      can :enable_otp, user
      can :update, user
    end
  end
end
