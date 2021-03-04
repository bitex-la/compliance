class LegalEntityDocketSeed < LegalEntityDocketBase
  include Garden::Seed

  before_create do
    self.country = country.upcase
  end
end
