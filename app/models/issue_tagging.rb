class IssueTagging < ApplicationRecord
  # We add this default_scope to allow others default_scopes
  # to cascade and apply admin taggings rules to the current query
  default_scope { joins(:issue).distinct }

  def self.taggable_type
    :issue
  end

  def self.tag_type
    :issue
  end

  include Tagging
end
