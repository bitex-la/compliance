# frozen_string_literal: true
module Abilities
  class Compliance
    include CanCan::Ability

    def initialize(user)
      can :read, ActiveAdmin::Page, name: 'Dashboard'
      can :read, [Observation,
        EventLog,
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

      can :manage, [Person,
        Issue,
        Tag,
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
        NoteSeed,
        PersonTagging,
        IssueTagging]

      can :read, user
      can :enable_otp, user
      can :update, user
    end
  end
end
