class AdminAccessAuthorization < ActiveAdmin::AuthorizationAdapter
  
  def admin_allowed_classes
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
      Note
    ] + restricted_allowed_classes
  end

  def admin_allowed_actions
    actions = {
      Issue => [:complete, :approve, :reject, :dismiss, :abandon],
      Person => [:enable, :disable, :reject, :download_files],
      AdminUser => [:read],
      EventLog => [:view_menu],
      ObservationReason => [:view_menu],
      Tag => [:view_menu],
      Workflow => [:finish],
    }
    actions.default = []
    actions
  end

  def restricted_allowed_actions
    actions = {
      AdminUser => [:read]
    }
    actions.default = []
    actions
  end

  def restricted_allowed_classes
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
      Attachment,
      EventLog
    ]
  end
  

  def authorized?(action, subject = nil)
    return true if user.is_super_admin?

    klass = subject.class == Class ? subject : subject.class

    if user.is_admin?
      return true if [:read, :create, :update].include?(action) && admin_allowed_classes.include?(klass)
      return admin_allowed_actions[klass].include?(action)
    end 
    
    return true if [:read, :create, :update].include?(action) && restricted_allowed_classes.include?(klass)
    restricted_allowed_actions[klass].include?(action)
  end
end