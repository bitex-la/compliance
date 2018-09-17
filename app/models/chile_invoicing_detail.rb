class ChileInvoicingDetail < ChileInvoicingDetailBase
  include Garden::Fruit
  def self.name_body(i)
    "RUT #{i.tax_id}"
  end
end
