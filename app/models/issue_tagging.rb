class IssueTagging < ApplicationRecord
  def self.taggable_type
    :issue
  end
  
  include Tagging
end