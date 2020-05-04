class Api::AffinitySeedsController < Api::EntityController
  def resource_class
    AffinitySeed
  end

  protected

  def related_person
    resource.issue.person_id
  end

  def get_mapper
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:issues, :people, :affinities, :affinity_seeds],
      issues: [],
      affinities: [],
      people: [],
      affinity_seeds: [
        :affinity_kind_code,
        :related_person,
        :copy_attachments,
        :replaces,
        :issue,
        :expires_at,
        :archived_at
      ]
  end
end
