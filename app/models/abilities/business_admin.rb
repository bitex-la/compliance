# frozen_string_literal: true

module Abilities
  class BusinessAdmin
    include CanCan::Ability

    def initialize(_user)
      can :manage, :all
      cannot :manage, [EventLog]
      cannot :create, AdminUser
      cannot :update, AdminUser
    end
  end
end
