class Identification < ApplicationRecord
  include Garden::Fruit
  include StaticModels::BelongsTo

  validates :issuer, country: true
  validates :identification_kind, inclusion: { in: IdentificationKind.all } 

  belongs_to :identification_kind

  def name
    build_name("#{identification_kind} #{number}, #{issuer}")
  end
end
