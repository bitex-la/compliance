class PersonTagging < ApplicationRecord
  def self.taggable_type
    :person
  end

  include Tagging
end