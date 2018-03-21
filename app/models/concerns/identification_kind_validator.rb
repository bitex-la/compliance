class IdentificationKindValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if IdentificationKind.find(value.to_i).nil?
      record.errors.add(:kind, "identification kind not found")
    end
  end
end
