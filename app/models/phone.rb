class Phone < ApplicationRecord
  include Garden::Fruit
  include Garden::Kindify
  validates :country, country: true

  kind_mask_for :phone_kind, "PhoneKind"

  def name
    [id, number, phone_kind, country].join(',')
  end
end
