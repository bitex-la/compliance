class TaxIdTypeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if TaxIdKind.find(value.to_i).nil?
      record.errors.add(:tax_id_type, "tax id type not found")
    end
  end
end
