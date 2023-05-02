class NoteBase < ApplicationRecord
  strip_attributes
  self.abstract_class = true

  validates :body, presence: true
  validates :title, length: { maximum: 255 }
  validates :note_type, presence: true

  def name_body
    title || body
  end

  NOTE_TYPE_VALUES = { fiat_note: 1, cripto_note: 2 }.freeze
  enum note_type: { unknown: 0 }.merge(NOTE_TYPE_VALUES)
end
