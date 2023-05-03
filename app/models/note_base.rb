class NoteBase < ApplicationRecord
  strip_attributes
  self.abstract_class = true

  validates :body, presence: true
  validates :title, length: { maximum: 255 }
  validates :note_type, presence: true

  def name_body
    title || body
  end

  NOTE_TYPE_VALUES = { fiat_note: 1, crypto_note: 2 }.freeze
  enum note_type: { other: 0 }.merge(NOTE_TYPE_VALUES)

  def self.notes_fiat_only_condition
    where(note_type: NOTE_TYPE_VALUES[:crypto_note]) if AdminUser.current_admin_user&.fiat_only?
  end
end
