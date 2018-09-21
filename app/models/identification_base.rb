class IdentificationBase < ApplicationRecord
  self.abstract_class = true
  validates :issuer, country: true
  ransackable_static_belongs_to :identification_kind

  def name_body
    "#{identification_kind} #{number}, #{issuer}"
  end
end
