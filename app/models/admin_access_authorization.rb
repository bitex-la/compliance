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
      Person => [:enable, :disable, :download_files]
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
      
      return true if admin_allowed_actions[klass].include?(action)
      
      return false
    end 

    return true if [:read, :create, :update].include?(action) && restricted_allowed_classes.include?(klass)
  end
end