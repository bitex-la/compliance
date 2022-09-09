class AffinityGraphBuilder
  attr_reader :edges
  attr_reader :affinity, :parent
  private :affinity, :parent

  def initialize(parent, affinity)
    @edges = []
    @affinity = affinity
    @parent = parent
  end

  def build_graph
    child = affinity.unscoped_related_one(parent)
    build_affinity_graph(parent, child)
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
        build_affinity_graph(child_person, child_of_child, new_already_gotten_affinities)
      end
    else
      raise "Unknown #{related_person_type}"
    end
  end

  def add_to_edge(parent_person, child_person)
    Rails.logger.info("Add edge: #{[parent_person.name, child_person.name]}")
    edges.push([parent_person, child_person])
  end
end
