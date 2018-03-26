class ReceiptTypeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if ReceiptType.find(value.to_i).nil?
      record.errors.add(:receipt_type, "receipt type not found")
    end
  end
end
