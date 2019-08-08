class Api::AffinitySeedsController < Api::SeedController
  def resource_class
    AffinitySeed
  end

  protected

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
        :expires_at
      ]
  end
end
