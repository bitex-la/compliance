class IssueTagging < ApplicationRecord

  default_scope { joins(:issue).distinct }

  def self.taggable_type
    :issue
  end

  def self.tag_type
    :issue
  end

  include Tagging
end
