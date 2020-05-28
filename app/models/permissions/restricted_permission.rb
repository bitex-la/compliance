# frozen_string_literal: true

module Permissions
  class RestrictedPermission < PermissionBase
    def initialize(user)
      super(user)
    end

    def allowed_classes
      [
        Issue,
        Person,
        Observation,
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
        FundDeposit,
        Attachment
      ]
    end

    def allowed_actions
      Hash.new([]).merge(
        AdminUser => [:read]
      )
    end
  end
end
