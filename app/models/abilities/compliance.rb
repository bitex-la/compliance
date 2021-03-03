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
        Note,
        Tag,
        ObservationReason]

      can :manage, [Person,
        Issue,
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

      can :full_read, Person
      can :create, Tag

      can :read, user
      can :enable_otp, user
      can :update, user
    end
  end
end
