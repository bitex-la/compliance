class ArgentinaInvoicingDetailSeed < ArgentinaInvoicingDetailBase
  include Garden::Seed

  before_create do
    self.country = country.upcase
  end
end
