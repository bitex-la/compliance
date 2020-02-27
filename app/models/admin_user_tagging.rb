class AdminUserTagging < ApplicationRecord
  def self.taggable_type
    :admin_user
  end

  def self.tag_type
    :person
  end

  include Tagging
end
