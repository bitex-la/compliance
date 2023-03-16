class IdentificationSeed < IdentificationBase
  include Garden::Seed

  before_create do
    self.issuer = issuer.upcase
  end

  before_save do
    self.number_normalized = normalize_number
  end

  def on_complete
    create_normalized_tax_id_alerts
  end

  private 

  def create_normalized_tax_id_alerts
    NormalizedIdentificationAlerts::CreateIdentificationAlerts.call(self)
  end
end
