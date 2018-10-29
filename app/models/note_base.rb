class NoteBase < ApplicationRecord
  strip_attributes
  self.abstract_class = true

   validates :body, presence: true

  def name_body
    title || body
  end  
end
