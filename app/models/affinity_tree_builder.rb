class AffinityTreeBuilder
  attr_reader :edges

  def initialize
    @edges = []
  end

  def build_affinity_graph(parent_person, child_person, already_gotten_affinities = [child_person.id, parent_person.id])
    case (related_person_type = child_person.person_type)
    when :natural_person
      add_to_edge(parent_person, child_person)
    when :legal_entity
      add_to_edge(parent_person, child_person)
      return if child_person.whitelabeler?

      new_already_gotten_affinities = [child_person.id].concat(already_gotten_affinities).uniq
      legal_entity_affinity_people = child_person
                                       .all_affinities
                                       .map { |related_person_affinity| related_person_affinity.unscoped_related_one(child_person) }
                                       .reject { |relevant_person| relevant_person.id.in?(already_gotten_affinities) }
      legal_entity_affinity_people.each do |child_of_child|
        obtain_affinity_tree(child_person, child_of_child, new_already_gotten_affinities)
      end
    else
      raise "Unknown #{related_person_type}"
    end
  end

  def obtain_affinity_tree(parent_person, child_person, already_gotten_affinities = [child_person.id, parent_person.id])
    add_to_edge(parent_person, child_person)

    case (related_person_type = child_person.person_type)
    when :natural_person
      [child_person, []]
    when :legal_entity
      # Not rendering whitelabelers affinities is a requirements definition given that they have thousands of relationships and
      # we don't need to show this information in the affinity tab.
      return [child_person, []] if child_person.whitelabeler?

      legal_entity_affinity_people = child_person
                                       .all_affinities
                                       .map { |related_person_affinity| related_person_affinity.unscoped_related_one(child_person) }
                                       .reject { |relevant_person| relevant_person.id.in?(already_gotten_affinities) }

      new_already_gotten_affinities = [child_person.id].concat(already_gotten_affinities).uniq
      [
        child_person,
        legal_entity_affinity_people.each do |child_of_child|
          obtain_affinity_tree(child_person, child_of_child, new_already_gotten_affinities)
        end
      ]
    else
      raise "Unknown #{related_person_type}"
    end
  end

  def add_to_edge(parent_person, child_person)
    Rails.logger.info("Add edge: #{[parent_person.name, child_person.name]}")
    edges.push([parent_person, child_person])
  end
end
