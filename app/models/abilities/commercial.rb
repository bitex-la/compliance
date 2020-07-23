# frozen_string_literal: true
module Abilities
  class Commercial
    include CanCan::Ability

    def initialize(user)
      can :read, ActiveAdmin::Page, name: 'Dashboard'
      can :read, [Issue, Person, Observation]
      can :read, user
      can :enable_otp, user
      can :update, user
    end
  end
end
