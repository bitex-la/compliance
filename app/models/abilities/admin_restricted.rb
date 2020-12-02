# frozen_string_literal: true

module Abilities
  class AdminRestricted
    include CanCan::Ability

    def initialize(_user)
      can :manage, :all
      cannot :manage, [EventLog]
    end
  end
end
