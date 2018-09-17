class NoteBase < ApplicationRecord
  self.abstract_class = true

  def name_body
    title || body
  end  
end
