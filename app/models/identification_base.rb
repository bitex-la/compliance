class IdentificationBase < ApplicationRecord
  strip_attributes
  self.abstract_class = true

  validates :issuer, country: true, length: { maximum: 255 }
  validates :number, :public_registry_authority, :public_registry_book, :number_normalized,
    :public_registry_extra_data, length: { maximum: 255 }

  ransackable_static_belongs_to :identification_kind

  def name_body
    "#{identification_kind} #{number}, #{issuer}"
  end

  def number_regx
    return Util::NormalizeIdentifications.argentina_tax_id_regx if self.issuer == 'AR'
    return Util::NormalizeIdentifications.chile_tax_id_regx if self.issuer == 'CL'
    ''
  end

  def normalize_number
    result = self.number&.delete(self.number_regx)
    return if result&.empty?
    result
  end
end
