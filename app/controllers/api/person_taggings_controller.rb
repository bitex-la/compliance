class Api::PersonTaggingsController < Api::SeedController
  def resource_class
    PersonTagging
  end

  def options_for_response
    { include: [] }
  end

  protected

  def get_mapper
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:people, :tags, :person_taggings],
      people: [],
      tags: [],
      person_taggings: [
        :tag,
        :person
      ]
  end
end
