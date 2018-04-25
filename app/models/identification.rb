class Identification < ApplicationRecord
  include Garden::Fruit
  include Garden::Kindify
  validates :issuer, country: true
  #validates :kind, identification_kind: true 

  kind_mask_for :identification_kind, "IdentificationKind"

  def name
    [id, number, identification_kind, issuer].join(',')    
  end
end
