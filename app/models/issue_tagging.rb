class IssueTagging < ApplicationRecord
  belongs_to :issue
  belongs_to :tag
  
  validates :issue, presence: true
  validates :tag,
    uniqueness: { 
      scope: :issue,
      message: "cant't contains duplicates in the same issue" 
    }
  
  validate :tag_type_must_be_issue

  def tag_type_must_be_issue
    return unless tag.nil? || tag.tag_type != "issue"
    errors.add(:tag, "can't be blank and must be an issue tag")
  end
end