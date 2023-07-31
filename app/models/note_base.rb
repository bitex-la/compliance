class NoteBase < ApplicationRecord
  strip_attributes
  self.abstract_class = true

  validates :body, presence: true
  validates :title, length: { maximum: 255 }

  def name_body
    title || body
  end
  
  def self.note_base_conditions
    return where("#{self.table_name}.created_at > ?", DateTime.parse(Settings.fiat_only.start_date)) if AdminUser.current_admin_user&.fiat_only?
    where(nil)
  end
end
