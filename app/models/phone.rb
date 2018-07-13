class Phone < ApplicationRecord
  include Garden::Fruit
  include Garden::Kindify
  validates :country, country: true

  validates :phone_kind, inclusion: { in: PhoneKind.all.map(&:code) }

  kind_mask_for :phone_kind, "PhoneKind"

  def name
    [self.class.name, id, number, phone_kind, country].join(',')
  end
end
