# frozen_string_literal: true
module Abilities
  class Operations
    include CanCan::Ability

    def initialize(user)
      can :read, [Issue, Person]
      can :create, [Issue, Person]
      can :update, Issue
      can :complete, Issue

      can :read, user
      can :enable_otp, user
      can :update, user
    end
  end
end
