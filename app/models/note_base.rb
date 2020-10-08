class NoteBase < ApplicationRecord
  strip_attributes
  self.abstract_class = true

  validates :body, presence: true
  validates :title, length: { maximum: 255 }

  def name_body
    title || body
  end
end
