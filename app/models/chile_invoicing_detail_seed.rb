class ChileInvoicingDetailSeed < ChileInvoicingDetailBase
  include Garden::Seed

  before_save do
    self.tax_id_normalized = normalize_tax_id
  end

  def on_complete
    create_normalized_tax_id_alerts
  end

  private
  
  def create_normalized_tax_id_alerts
    NormalizedIdentificationAlerts::CreateChileInvoicingAlerts.call(self)
  end
end
