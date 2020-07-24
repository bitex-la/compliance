# frozen_string_literal: true
module Abilities
  class Operations
    include CanCan::Ability

    def initialize(user)
      can :create, [Issue, Person]
      can :update, Issue
      can :complete, Issue

      can :manage, [
        NaturalDocketSeed,
        LegalEntityDocketSeed,
        DomicileSeed,
        IdentificationSeed,
        AllowanceSeed,
        AffinitySeed,
        ArgentinaInvoicingDetailSeed,
        ChileInvoicingDetailSeed,
        RiskScoreSeed,
        PhoneSeed,
        EmailSeed,
        Attachment,
        NoteSeed]

      can :read, [
        Issue, 
        Person,
        FundDeposit,
        FundTransfer,
        FundWithdrawal,
        NaturalDocket,
        LegalEntityDocket,
        Domicile,
        Identification,
        Allowance,
        Affinity,
        ArgentinaInvoicingDetail,
        ChileInvoicingDetail,
        RiskScore,
        Phone,
        Email,
        Note]

      can :read, user
      can :enable_otp, user
      can :update, user
    end
  end
end
