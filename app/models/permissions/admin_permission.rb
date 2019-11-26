module Permissions
  class AdminPermission < RestrictedPermission
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
      actions = {
        Issue => [:complete, :approve, :reject, :dismiss, :abandon],
        Person => [:enable, :disable, :reject, :download_profile],
        AdminUser => [:read],
        Tag => [:destroy],
        Workflow => [:finish],
        PersonTagging => [:destroy],
        IssueTagging => [:destroy],
        EventLog => [:view_menu]
      }
      actions.default = []
      actions
    end
  end
end