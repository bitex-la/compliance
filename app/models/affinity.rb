class Affinity < ApplicationRecord 
  include Garden::Fruit
  include StaticModels::BelongsTo

  belongs_to :related_person, class_name: 'Person'
  validates  :affinity_kind, inclusion: { in: AffinityKind.all }
  belongs_to :affinity_kind

  def self.name_body(a)
    "#{a.affinity_kind} #{a.related_person.name}"
  end
end
