class Identification < ApplicationRecord
  include Garden::Fruit
  validates :issuer, country: true
  validates :kind, identification_kind: true 

  def name
    [id, number, kind, issuer].join(',')    
  end
end
