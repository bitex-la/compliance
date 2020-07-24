# frozen_string_literal: true
module Abilities
  class Restricted
    include CanCan::Ability

    def initialize(user)
      cannot :manage, :all
    end
  end
end
