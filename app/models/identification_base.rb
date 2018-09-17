class IdentificationBase < ApplicationRecord
  self.abstract_class = true
  validates :issuer, country: true
  validates :identification_kind, inclusion: { in: IdentificationKind.all } 
  ransackable_static_belongs_to :identification_kind
end
