class ArgentinaInvoicingDetailSeed < ArgentinaInvoicingDetailBase
  include Garden::Seed

  before_create do
    self.country = country.upcase
  end

  after_create do
    create_normalized_tax_id_alerts
  end

  private 

  def create_normalized_tax_id_alerts
    InvoicingDetail::CreateNormalizedTaxIdAlerts.call(self)
  end
end
