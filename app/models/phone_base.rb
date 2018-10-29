class PhoneBase < ApplicationRecord
  strip_attributes
  self.abstract_class = true
  validates :phone_kind, inclusion: { in: PhoneKind.all }
  ransackable_static_belongs_to :phone_kind, class_name: "PhoneKind"

  def name_body
    number
  end

  private
  def set_default_values
    self.has_whatsapp = false
    self.has_telegram = false
  end
end
