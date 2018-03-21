class LegalEntityDocket < ApplicationRecord
  include Garden::Fruit
  validates :country, country: true

  def name
    [id, commercial_name, legal_name].join(',')    
  end
end
