class DomicileSeed < DomicileBase
  include Garden::Seed

  before_create do
    self.country = country.upcase
  end
end
