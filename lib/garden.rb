module Garden 
  module Seed
    extend ActiveSupport::Concern

    included do
      belongs_to :issue
      belongs_to :fruit, class_name: "#{name[0..-5]}", foreign_key: "#{name[0..-5].underscore}_id", optional: true
      has_many :attachments, as: :attached_to

      accepts_nested_attributes_for :attachments, :allow_destroy => true
    end  
  end

  module Fruit
    extend ActiveSupport::Concern

    included do
      belongs_to :person 
      has_one  :seed, required: false, class_name: "#{name}Seed"
      has_many :attachments, as: :attached_to

      scope :current, ->(person) { where(person: person, replaced_by_id: nil) }
    end
  end
end

