# Our database is a Garden, where Issues have Seeds, which get curated by admins.
# An Issue belongs to a Person, and once curated, the Issue's seeds give Fruits
# which become associated to the Person.
# Each Fruit remembers its seed, and each Seed knows its fruit.
# Other than that, Seeds belong to Issues and Fruits belong to People.
module Garden 
  module Seed
    extend ActiveSupport::Concern

    included do
      cattr_accessor :naming { Naming.new(name) }
      belongs_to :issue
      belongs_to :fruit, class_name: naming.fruit, optional: true
      has_many :attachments, as: :attached_to_seed

      if column_names.include?('replaces_id')
        belongs_to :replaces, class_name: naming.fruit, optional: true
      end

      accepts_nested_attributes_for :attachments, :allow_destroy => true
    end  

    def harvest!
      fruit = self.class.naming.fruit.constantize.new(attributes.except(
        *%w(id created_at updated_at issue_id fruit_id replaces_id copy_attachments)
      ))
      fruit.person = issue.person
      fruit.save!
      update!(fruit: fruit)
      attachments.each{|a| a.update!(
        attached_to_fruit: fruit,
        attached_to_seed: nil,
        person: issue.person
      )}

      if respond_to?(:replaces)
        if replaces
          replaces.update!(replaced_by: fruit)
          replaces.attachments.each{ |a| a.update!(
            attached_to_fruit: fruit,
            attached_to_seed: nil,
            person: issue.person
          )} if copy_attachments
        end
      else
         old_fruits =  fruit.person.send(self.class.naming.plural)
          .current.where('id != ?', fruit.id)
         
         if copy_attachments 
           old_fruits.each do |old_fruit|
             old_fruit.attachments.each{ |a| a.update!(
               attached_to_fruit: fruit,
               attached_to_seed: nil,
               person: issue.person
             )} 
           end
         end
         old_fruits.update_all(replaced_by_id: fruit.id)
      end
 
      fruit
    end
  end

  module Fruit
    extend ActiveSupport::Concern

    included do
      belongs_to :person 
      has_one :seed, required: false, class_name: Naming.new(name).seed,
        foreign_key: :fruit_id
      belongs_to :replaced_by, required: false, class_name: name
      has_one :replaces, required: false, class_name: name,
        foreign_key: :replaced_by_id
      has_many :attachments, as: :attached_to_fruit

      scope :current, -> { where(replaced_by_id: nil) }
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

    def plural
      base.pluralize
    end

    def seed_plural
      "#{base}_seeds"
    end
  end
end

