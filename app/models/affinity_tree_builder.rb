class AffinityTreeBuilder
  # In order to avoid an endless loop of affinities, the root_person param is the root of the affinity tree that starts rendering
  # its affinities. It's used as a mark to avoid rendering more than once that resource.
  def self.obtain_affinity_tree(root_person, related_person, already_gotten_affinities = [related_person.id, root_person.id])
    case (related_person_type = related_person.person_type)
    when :natural_person
      [related_person, []]
    when :legal_entity
      # Not rendering whitelabelers affinities is a requirements definition given that they have thousands of relationships and
      # we don't need to show this information in the affinity tab.
      return [related_person, []] if related_person.whitelabeler?

      legal_entity_affinity_people = related_person
                                       .all_affinities
                                       .map { |related_person_affinity| related_person_affinity.unscoped_related_one(related_person) }
                                       .reject { |relevant_person| relevant_person == root_person }
                                       .reject { |relevant_person| relevant_person.id.in?(already_gotten_affinities) }

      new_already_gotten_affinities = [related_person.id].concat(already_gotten_affinities).uniq
      [
        related_person,
        legal_entity_affinity_people.map do |p|
          obtain_affinity_tree(root_person, p, new_already_gotten_affinities)
        end
      ]
    else
      raise "Unknown #{related_person_type}"
    end
  end
end
