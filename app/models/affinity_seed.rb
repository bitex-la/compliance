class AffinitySeed < AffinityBase
  include Garden::Seed
  validate :linked_once_in_issue

    # same_person affinity validation
  validate :only_one_same_person_affinity,
           :manual_same_person_affinities_with_no_relations,
           :same_person_father_son_consistency

  def only_one_same_person_affinity
    # validates that only one same_personn affinity can exist in a issue
    # and must be the only affinity seed.
    # I decided to create this restriction because the fulfiment process of
    # a same_person relationship could be intrincate
    # (see cases in spec/services/same_person_affinity/finder_spec.rb)
    return if issue.nil?

    return unless affinity_kind == AffinityKind.same_person &&
                  issue.affinity_seeds.count > 1

    errors.add(:reason, "there can be only one same_person affinity per issue. And only one")
  end

  def manual_same_person_affinities_with_no_relations
    # validates that a manual same_person affinity relates
    # persons that has no existing same_person relations.
    # because fulfil process is not called in this cases
    return if issue.nil?

    return unless affinity_kind == AffinityKind.same_person && !auto_created

    return unless issue.person.affinities.exists?(affinity_kind_id: AffinityKind.same_person.id) ||
                  related_person.affinities.exists?(affinity_kind_id: AffinityKind.same_person.id)

    errors.add(:reason, "no previous relations could exist between persons in a new manual same_person relationship.")
  end

  def same_person_father_son_consistency
    # in a same person affinity, the oldest (lower ID)
    # must be the "father" issue's person
    # In case of a manual creation, we need to make sure of this.
    return if issue.nil?

    return unless (affinity_kind == AffinityKind.same_person && !auto_created) &&
                  issue.affinity_seeds.count > 1 &&
                  issue.person.id < related_person_id

    # TODO: change the copy of the error. more clear to the end user
    errors.add(:reason, "the oldest person in the system (lower id) must be the first person related")
  end

  before_save :add_update_affinity_tag
  after_destroy :remove_affinity_tag

  def not_linked_to_itself
    return if issue.nil?
    return unless related_person.try(:id) == issue.person.id

    errors.add(:base, 'cannot_link_to_itself')
  end

  def linked_once_by_affinity
    return if issue.nil?
    return unless affinity_exist?(issue.person, related_person, affinity_kind, archived_at) ||
                  affinity_exist?(related_person, issue.person, affinity_kind, archived_at)

    errors.add(:base, 'affinity_already_exists')
  end

  def linked_once_in_issue
    return if issue.nil?
    return unless affinity_defined?(issue, related_person, affinity_kind)

    errors.add(:base, 'affinity_already_defined')
  end

  def affinity_defined?(issue, related_one, kind)
    active_issues = issue.person.issues
      .where(aasm_state: %w(draft new observed answered))
      .pluck(:id)

    AffinitySeed.where(issue_id: active_issues, related_person: related_one,
      affinity_kind_id: kind.try(:id))
      .where.not(id: id).count > 0
  end

  def get_label(current_issue)
    return affinity_kind.code if person == current_issue.person
    return affinity_kind.inverse if related_person == current_issue.person
  end

  def related_one(current_issue)
    return related_person if person == current_person
    return current_issue.person if related_person == current_issue.person
  end

  def before_harvest
    SamePersonAffinity::Fulfilment.call(self)
  end

  def after_harvest
    SamePersonAffinity::Fulfilment.after_process(self)
  end

  private

  def add_update_affinity_tag
    affinity_kind_changed = affinity_kind_id_changed? && affinity_kind_id_was
    related_person_changed = related_person_id_changed? && related_person_id_was

    if affinity_kind_changed
      kind = AffinityKind.find(affinity_kind_id_was)
      tag_name = kind.affinity_to_tag
      inverse_tag_name = kind.inverse_of_tag
      if related_person_changed
        Person
          .find(related_person_id_was)
          .remove_tag(tag_name) if tag_name
      else
        related_person.remove_tag(tag_name) if tag_name
      end
      person.remove_tag(inverse_tag_name) if inverse_tag_name
    end

    if related_person_changed
      unless affinity_kind_changed
        Person
          .find(related_person_id_was)
          .remove_tag(affinity_kind.affinity_to_tag) if affinity_kind.affinity_to_tag
      end
    end

    person.add_tag(affinity_kind.inverse_of_tag) if affinity_kind.inverse_of_tag
    related_person.add_tag(affinity_kind.affinity_to_tag) if affinity_kind.affinity_to_tag
  end

  def remove_affinity_tag
    person.remove_tag(affinity_kind.inverse_of_tag) if affinity_kind.inverse_of_tag
    related_person.remove_tag(affinity_kind.affinity_to_tag) if affinity_kind.affinity_to_tag
  end
end
