class GenderValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if GenderKind.find(value.to_s).nil?
      record.errors.add(:gender, "gender not found")
    end
  end
end
