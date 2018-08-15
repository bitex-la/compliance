class Identification < ApplicationRecord
  include Garden::Fruit
  include StaticModels::BelongsTo
  
  validates :issuer, country: true
  validates :identification_kind, inclusion: { in: IdentificationKind.all } 

  belongs_to :identification_kind, class_name: "IdentificationKind"

  def name
    replaced = "*" if replaced_by
    "##{id}#{replaced}: #{identification_kind} #{number}, #{issuer}"
  end
end
