class Api::AffinitySeedsController < Api::SeedController
  def resource_class
    AffinitySeed
  end

  protected

  def get_mapper
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:issues, :affinities, :affinity_seeds],
      issues: [],
      affinities: [],
      affinity_seeds: [
        :affinity_kind_code,
        :related_person,
        :attachments,
        :copy_attachments,
        :replaces,
        :issue
      ]
  end
end
