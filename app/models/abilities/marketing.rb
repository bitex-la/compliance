# frozen_string_literal: true
module Abilities
  class Marketing
    include CanCan::Ability

    def initialize(user)
      can :read, Person
    end
  end
end
