class Phone < ApplicationRecord
  include Garden::Fruit
  include StaticModels::BelongsTo

  validates :country, country: true

  validates :phone_kind, inclusion: { in: PhoneKind.all }

  belongs_to :phone_kind, class_name: "PhoneKind"

  def name
    [self.class.name, id, number, phone_kind, country].join(',')
  end
end
