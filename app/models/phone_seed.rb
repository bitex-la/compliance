class PhoneSeed < ApplicationRecord
  include Garden::Seed
  include Garden::Kindify

  after_initialize :set_default_values, unless: :persisted?

  validates :phone_kind, inclusion: { in: PhoneKind.all.map(&:code) }

  kind_mask_for :phone_kind, "PhoneKind"

  private
  def set_default_values
    self.has_whatsapp = false
    self.has_telegram = false
  end
end
