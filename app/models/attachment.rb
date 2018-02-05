class Attachment < ApplicationRecord
  belongs_to :person
  belongs_to :seed_to, polymorphic: true, optional: true
end
