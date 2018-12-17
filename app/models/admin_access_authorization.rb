class AdminAccessAuthorization < ActiveAdmin::AuthorizationAdapter
  def authorized?(action, subject = nil)
    if user.is_restricted
      klass = subject.class == Class ? subject : subject.class
      
      case action
      when :read, :create, :update
        [ Issue, 
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
        ].include?(klass)
      else
        false
      end
    else
      true
    end
  end
end