# frozen_string_literal: true
module Abilities
  class Admin
    include CanCan::Ability

    def initialize(user)
      can :manage, :all
    end
  end
end
