class Identification < ApplicationRecord
  include Garden::Fruit
  include Garden::Kindify
  validates :issuer, country: true
  validates :identification_kind, inclusion: { in: IdentificationKind.all.map(&:code) } 

  kind_mask_for :identification_kind, "IdentificationKind"

  def name
    [id, number, identification_kind, issuer].join(',')    
  end
end
