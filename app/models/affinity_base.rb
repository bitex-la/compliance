class AffinityBase < ApplicationRecord
  self.abstract_class = true
  belongs_to :related_person, class_name: 'Person'
  validates  :affinity_kind, inclusion: { in: AffinityKind.all }
  validate   :linked_once_by_affinity
  validate   :not_linked_to_itself

  ransackable_static_belongs_to :affinity_kind

  def name_body
    "#{affinity_kind} #{related_person.try(:name)}"
  end

  def affinity_exist?(person, related_one, kind)
    Affinity.where(person: person, related_person: related_one, 
      affinity_kind_id: kind.try(:id))
      .where.not(id: id).count > 0
  end
end
