class IdentificationSeed < IdentificationBase
  include Garden::Seed

  before_create do
    self.issuer = issuer.upcase
  end
end
