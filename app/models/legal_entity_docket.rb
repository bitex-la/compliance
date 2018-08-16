class LegalEntityDocket < ApplicationRecord
  include Garden::Fruit
  validates :country, country: true

  def name
    build_name("#{commercial_name} #{legal_name}")
  end
end
