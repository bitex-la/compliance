# frozen_string_literal: true
module Abilities
  class Operations
    include CanCan::Ability

    def initialize(user)
      can :read, [Issue, Person]
      can :read, user
      can :create, [Issue, Person]
      can :update, Issue
      can :enable_otp, user
      can :update, user
      can :complete, Issue
    end
  end
end
