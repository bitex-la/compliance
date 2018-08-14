class Identification < ApplicationRecord
  include Garden::Fruit
  include Garden::Kindify
  validates :issuer, country: true
  validates :identification_kind, inclusion: { in: IdentificationKind.all.map(&:code) } 

  kind_mask_for :identification_kind, "IdentificationKind"

  def name
    replaced = "*" if replaced_by
    "##{id}#{replaced}: #{identification_kind} #{number}, #{issuer}"
  end
end
