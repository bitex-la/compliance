class Tag < ApplicationRecord
  enum tag_type: [:person, :issue]

  validates :name, presence: true, length: { maximum: 30 }, uniqueness: 
    { scope: :tag_type, message: "cant't contains duplicates in the same tag type" }, format: 
    { with: /\A[a-zA-Z0-9\-]+\z/ , message: "only support letters, numbers and hyphen" }
  validates :tag_type, presence: true
end