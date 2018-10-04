class AffinityBase < ApplicationRecord
  self.abstract_class = true
  belongs_to :related_person, class_name: 'Person'
  validates  :affinity_kind, inclusion: { in: AffinityKind.all }
  ransackable_static_belongs_to :affinity_kind

  def name_body
    "#{affinity_kind} #{related_person.try(:name)}"
  end
end
