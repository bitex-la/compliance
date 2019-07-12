class Tag < ApplicationRecord
  enum tag_type: [:person, :issue]

  validates :name, 
    presence: true, 
    length: { maximum: 30 }, 
    uniqueness: { 
      scope: :tag_type,
      message: "cant't contains duplicates in the same tag type" 
    }, 
    format: { 
      with: /\A[a-zA-Z0-9\-]+\z/, 
      message: "only support letters, numbers and hyphen" 
    }
  
  validates :tag_type, presence: true

  before_destroy :can_destroy?, prepend: true

  ransacker :tag_type, formatter: proc {|v| tag_types[v]}

  scope :people, -> { Tag.person.order(name: :asc) }
  scope :issues, -> { Tag.issue.order(name: :asc) }

  private

  def can_destroy?
    return unless {
      "person" => PersonTagging,
      "issue" => IssueTagging
    }[tag_type].where(tag: self).exists?

    errors[:base] << "Can't be destroy because there are relations with #{tag_type} created"
    throw :abort
  end
end