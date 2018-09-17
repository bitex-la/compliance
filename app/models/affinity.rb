class Affinity < AffinityBase
  include Garden::Fruit
  def self.name_body(a)
    "#{a.affinity_kind} #{a.related_person.name}"
  end
end
