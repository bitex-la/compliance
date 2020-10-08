class IdentificationBase < ApplicationRecord
  strip_attributes
  self.abstract_class = true

  validates :issuer, country: true, length: { maximum: 255 }
  validates :number, :public_registry_authority, :public_registry_book,
    :public_registry_extra_data, length: { maximum: 255 }

  ransackable_static_belongs_to :identification_kind

  def name_body
    "#{identification_kind} #{number}, #{issuer}"
  end
end
