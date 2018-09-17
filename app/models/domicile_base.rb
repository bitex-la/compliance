class DomicileBase < ApplicationRecord
  self.abstract_class = true
  validates :country, country: true 
end
