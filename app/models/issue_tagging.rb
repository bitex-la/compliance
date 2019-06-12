class IssueTagging < ApplicationRecord
  belongs_to :issue
  belongs_to :tag
  validates :issue, presence: true
  validates :tag, presence: true,
    uniqueness: { 
      scope: :issue,
      message: "cant't contains duplicates in the same issue" 
    }
end