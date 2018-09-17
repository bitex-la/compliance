class ArgentinaInvoicingDetail < ArgentinaInvoicingDetailBase
  include Garden::Fruit

  def self.name_body(i)
    "#{i.tax_id_kind} #{i.tax_id}"
  end
end
