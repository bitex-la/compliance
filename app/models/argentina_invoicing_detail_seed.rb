class ArgentinaInvoicingDetailSeed < ArgentinaInvoicingDetailBase
  include Garden::Seed

  before_create do
    self.country = country.upcase
  end

  before_save do
    self.tax_id_normalized = self&.tax_id&.delete(self.tax_id_regx) || ''
  end 

  def on_complete
    create_normalized_tax_id_alerts
  end

  private 

  def create_normalized_tax_id_alerts
    InvoicingDetail::CreateNormalizedTaxIdAlerts.call(self)
  end
end
