class MaritalStatusValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if MaritalStatusKind.find(value.to_i).nil?
      record.errors.add(:marital_status, "marital status not found")
    end
  end
end
