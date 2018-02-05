class DomicileSeed < ApplicationRecord
  belongs_to :issue
  has_many :attachments, as: :seed_to
end
