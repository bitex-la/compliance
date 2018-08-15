class PhoneSeed < ApplicationRecord
  include Garden::Seed
  include StaticModels::BelongsTo

  after_initialize :set_default_values, unless: :persisted?

  validates :phone_kind, inclusion: { in: PhoneKind.all }

  belongs_to :phone_kind, class_name: "PhoneKind"

  private
  def set_default_values
    self.has_whatsapp = false
    self.has_telegram = false
  end
end
