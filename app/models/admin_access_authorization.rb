class AdminAccessAuthorization < ActiveAdmin::AuthorizationAdapter
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
  

  def authorized?(action, subject = nil)
    return true unless user.is_restricted?

    klass = subject.class == Class ? subject : subject.class
    return true if [:read, :create, :update].include?(action) && allowed_classes.include?(klass)
  end
end