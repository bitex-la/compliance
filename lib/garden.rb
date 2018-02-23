# Our database is a Garden, where Issues have Seeds, which get curated by admins.
# An Issue belongs to a Person, and once curated, the Issue's seeds give Fruits
# which become associated to the Person.
# Each Fruit remembers its seed, and each Seed knows its fruit.
# Other than that, Seeds belong to Issues and Fruits belong to People.
module Garden 
  module Seed
    extend ActiveSupport::Concern

    included do
      naming = Naming.new(name)
      belongs_to :issue
      belongs_to :fruit, class_name: naming.fruit,
        foreign_key: naming.foreign_key, optional: true
      has_many :attachments, as: :attached_to

      accepts_nested_attributes_for :attachments, :allow_destroy => true
    end  
  end

  module Fruit
    extend ActiveSupport::Concern

    included do
      belongs_to :person 
      has_one  :seed, required: false, class_name: Naming.new(name).seed
      has_many :attachments, as: :attached_to

      scope :current, ->(person) { where(person: person, replaced_by_id: nil) }
    end
  end

  class Naming
    attr_accessor :base

    def initialize(original)
      self.base = original.to_s.underscore.singularize
        .gsub(/_serializer$/, '')
        .gsub(/_seed/, '')
    end

    def fruit(suffix='')
      "#{base.classify}#{suffix}"
    end

    def seed
      fruit('Seed')
    end

    def serializer
      fruit('Serializer')
    end

    def seed_serializer
      fruit('SeedSerializer')
    end

    def foreign_key
      "#{base}_id"
    end

    def plural
      base.pluralize
    end

    def seed_plural
      "#{base}_seeds"
    end
  end
end

