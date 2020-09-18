# frozen_string_literal: true
module Abilities
  class Commercial
    include CanCan::Ability

    def initialize(user)
      can :read, ActiveAdmin::Page, name: 'Dashboard'
      can :full_read, Person

      can :read, [Observation,
        Person,
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

      can :create, [Issue,
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

      can :update, [Issue,
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

      can :destroy, [NaturalDocketSeed,
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
