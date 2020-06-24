# frozen_string_literal: true

module Permissions
  class AdminPermission < RestrictedPermission
    def initialize(user)
      super(user)
    end

    def allowed_classes 
      super +
      [
        Affinity,
        ObservationReason,
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
        Tag
      ]
    end

    def allowed_actions
      super.merge(
        Issue => [:complete, :approve, :reject, :dismiss, :abandon],
        Person => [:enable, :disable, :reject, :download_profile_basic, :download_profile_full],
        Tag => [:destroy],
        Workflow => [:finish],
        PersonTagging => [:destroy],
        IssueTagging => [:destroy],
        EventLog => [:view_menu]
      )
    end
  end
end
