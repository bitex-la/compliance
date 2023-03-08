class ChileInvoicingDetailSeed < ChileInvoicingDetailBase
  include Garden::Seed

  after_create do
    create_normalized_tax_id_alerts
  end

  private
  
  def create_normalized_tax_id_alerts
    InvoicingDetail::CreateNormalizedTaxIdAlerts.call(self)
  end
end
