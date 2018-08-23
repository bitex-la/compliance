class Identification < ApplicationRecord
  include Garden::Fruit
  include StaticModels::BelongsTo

  validates :issuer, country: true
  validates :identification_kind, inclusion: { in: IdentificationKind.all } 

  belongs_to :identification_kind

  def self.name_body(i)
    "#{i.identification_kind} #{i.number}, #{i.issuer}"
  end
end
