# frozen_string_literal: true

module Abilities
  class BusinessRestricted
    include CanCan::Ability

    def initialize(_user)
      can :manage, :all
      cannot :manage, [EventLog]
    end
  end
end
