# Our database is a Garden, where Issues have Seeds, which get curated by admins.
# An Issue belongs to a Person, and once curated, the Issue's seeds give Fruits
# which become associated to the Person.
# Each Fruit remembers its seed, and each Seed knows its fruit.
# Other than that, Seeds belong to Issues and Fruits belong to People.
module FastJsonapi
  class Relationship
    def id_hash_from_record(record, record_types)
      associated_record_type = record_types[record.class] ||=
        run_key_transform(record.class.name.demodulize.underscore.pluralize)
      id_hash(record.id, associated_record_type)
    end
  end
end

module Garden
  module SelfHarvestable
    extend ActiveSupport::Concern

    included do 
      after_save -> { self_harvest! }
    end

    def self_harvest!
      issue.approve! if issue.may_approve?
    end
  end

  module Seed
    extend ActiveSupport::Concern

    included do
      cattr_accessor :naming { Naming.new(name) }
      belongs_to :issue
      has_one :person, through: :issue
      def person
        # If a seed has an issue, it has a person. Even before it's been saved.
        # has_one through seems to be ignoring the in-memory object.
        issue&.person || super
      end

      belongs_to :fruit, class_name: naming.fruit, optional: true
      has_many :attachments, as: :attached_to_seed

      has_many :observations, as: :observable

      before_validation do 
        attachments.each do |a|
          a.attached_to_seed = self if a.attached_to.nil?
        end
        
        observations.each do |o|
          o.observable = self unless o.observable 
          o.issue = o.observable.issue unless o.issue
        end
      end

      validate do
        next if issue.nil?
        state = issue.changes[:aasm_state].try(:first) || issue.state
        next if %w(draft new observed answered).include?(state)
        errors.add(:base, 'no_more_updates_allowed')
      end

      validate :expires_at_cannot_be_in_the_past

      def expires_at_cannot_be_in_the_past
        return if expires_at.nil?
        validation_date = created_at.try(:to_date) || Date.current
        return if expires_at >= validation_date
        errors.add(:expires_at, "can't be in the past")
      end

      if column_names.include?('replaces_id')
        belongs_to :replaces, class_name: naming.fruit, optional: true
      end

      accepts_nested_attributes_for :attachments, :allow_destroy => true
      accepts_nested_attributes_for :observations, :allow_destroy => true

      before_destroy :destroy_observations

      def destroy_observations
        observations.destroy_all
      end

      # We add this default_scope to allow others default_scopes
      # to cascade and apply admin taggings rules to the current query
      default_scope { joins(:issue).distinct }

      after_save { person.expire_action_cache }

      def name
        "#{self.class.name}: #{name_body}".truncate(40, omission:'…')
      end

      scope :others_active_seeds, -> (issue) { 
        joins(:issue)
          .where("issues.id != ?", issue.id)
          .where("issues.aasm_state IN (?)",%i{new observed answered})
          .where("issues.person_id = ?", issue.person.id)
      }
    end

    def harvest!
      fruit = self.class.naming.fruit.constantize.new(attributes.except(
        *%w(id created_at updated_at issue_id fruit_id replaces_id copy_attachments expires_at)
      ))
      fruit.person = issue.person
      update!(fruit: fruit)
      fruit.save!
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
          .current.where.not(id: fruit.id).distinct(false)

        if respond_to?(:copy_attachments)
          if copy_attachments
            old_fruits.each do |old_fruit|
              old_fruit.attachments.each{ |a| a.update!(
                attached_to_fruit: fruit,
                attached_to_seed: nil,
                person: issue.person
              )}
            end
          end
        end
        old_fruits.update_all(replaced_by_id: fruit.id)
      end

      create_deferred_issue(fruit) unless expires_at.nil?

      fruit
    end

    def create_deferred_issue(fruit)
      defer_until = expires_at < Date.current ? nil : expires_at
      new_issue = issue.person.issues.create(defer_until: defer_until, state: 'new')
      new_issue.add_seeds_replacing([fruit])
      new_issue.save!
    end
  end

  module Fruit
    extend ActiveSupport::Concern
    include PersonScopeable

    included do
      belongs_to :person
      has_one :seed, required: false, class_name: Naming.new(name).seed,
        foreign_key: :fruit_id
      belongs_to :replaced_by, required: false, class_name: name
      has_one :replaces, required: false, class_name: name,
        foreign_key: :replaced_by_id
      has_many :attachments, as: :attached_to_fruit

      after_save{ person.expire_action_cache }

      scope :current, -> { 
        where(replaced_by_id: nil)
        .where("archived_at is NULL OR archived_at > ?", Date.current)
        .includes(:attachments)
        .order(updated_at: :desc) 
      }

      scope :archived, ->(person) { 
        where("archived_at <= ?", Date.current)
        .where(person: person)
        .order(archived_at: :desc) 
      }

      def previous_versions
        [replaces, *replaces.try(:previous_versions)].compact
      end

      def others_for_person
        self.class.where(person: person, replaced_by: nil).where.not(id: self)
      end

      def issue
        seed.try(:issue)
      end

      def name
        "#{self.class.name}##{id}#{"旧" if replaced_by}: #{name_body}"
          .truncate(40, omission:'…')
      end
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
