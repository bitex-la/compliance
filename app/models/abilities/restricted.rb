# frozen_string_literal: true
module Abilities
  class Restricted
    include CanCan::Ability

    def initialize(user)
      can :read, Person
    end
  end
end
