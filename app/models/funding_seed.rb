class FundingSeed < ApplicationRecord
  belongs_to :issue
  belongs_to :funding, optional: true
  has_many :attachments, as: :seed_to
end
