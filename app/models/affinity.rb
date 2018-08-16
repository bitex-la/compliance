class Affinity < ApplicationRecord 
  include Garden::Fruit
  include StaticModels::BelongsTo

  belongs_to :related_person, class_name: 'Person'
  validates  :affinity_kind, inclusion: { in: AffinityKind.all }
  belongs_to :affinity_kind

  def name
    build_name("#{affinity_kind} #{related_person.name}")
  end
end
