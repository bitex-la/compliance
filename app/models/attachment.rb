class Attachment < ApplicationRecord
  belongs_to :person, optional: true
  belongs_to :attached_to_fruit, polymorphic: true, optional: true
  belongs_to :attached_to_seed, polymorphic: true, optional: true
  has_attached_file :document, optional: true

  validates_attachment :document,
    content_type: { 
      content_type: [
        'image/jpeg', 
        'image/jpg',
        'image/gif', 
        'image/png',
        'application/pdf',
        'application/zip',
        'application/x-rar-compressed' 
    ]}
  
  validates_attachment_file_name :document, matches: [
    /png\z/,
    /jpg\z/, 
    /jpeg\z/,
    /pdf\z/,
    /gif\z/,
    /zip\z/,
    /rar\z/,
  ]
end
