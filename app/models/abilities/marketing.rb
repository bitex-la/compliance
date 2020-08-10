# frozen_string_literal: true
module Abilities
  class Marketing
    include CanCan::Ability

    def initialize(user)
      can :read, Person
      cannot :full_read, Person
      can :read, user
      can :enable_otp, user
      can :update, user
    end
  end
end
