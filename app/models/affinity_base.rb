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

  def affinity_exist?(person, related_one, kind, archived_at)
    affinities = Affinity.current.where(person: person,
      related_person: related_one,
      affinity_kind_id: kind.try(:id))
      .where.not(id: id)
      .pluck(:archived_at)

    # Only allow to create duplicate affinities if the new one has archive_date
    !affinities.count.zero? && !(affinities.first.nil? && !archived_at.nil?)
  end
end
