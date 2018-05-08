class LegalEntityDocketSeed < ApplicationRecord
  include Garden::Seed
  validates :country, country: true

  def name
    [id, commercial_name, legal_name].join(',')
  end
end
