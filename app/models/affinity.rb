class Affinity < ApplicationRecord 
  include Garden::Fruit
  include StaticModels::BelongsTo

  belongs_to :related_person, class_name: 'Person'
  validates  :affinity_kind, inclusion: { in: AffinityKind.all }
  
  belongs_to :affinity_kind, class_name: "AffinityKind"

  def name 
    [self.class.name, id, person.name, related_person.name, affinity_kind].join(',')
  end
end
