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
        Person => [:enable, :disable, :reject, :download_files],
        AdminUser => [:read],
        EventLog => [:view_menu],
        ObservationReason => [:view_menu],
        Tag => [:view_menu, :destroy],
        Workflow => [:finish],
        PersonTagging => [:destroy],
        IssueTagging => [:destroy]
      }
      actions.default = []
      actions
    end
  end
end