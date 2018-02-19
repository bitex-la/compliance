class QuotaSeed < ApplicationRecord
  belongs_to :issue
  belongs_to :quota, optional: true, class_name: "Quotum"
  has_many :attachments, as: :seed_to

  accepts_nested_attributes_for :attachments, :allow_destroy => true
end
