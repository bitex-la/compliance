class Api::PersonTaggingsController < Api::EntityController
  def resource_class
    PersonTagging
  end

  def options_for_response
    { include: [] }
  end

  protected

  def get_mapper
    mapper = JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:people, :tags, :person_taggings],
      people: [],
      tags: [],
      person_taggings: [
        :tag,
        :person
      ]

    return mapper unless mapper.data

    return mapper if mapper.data.person.tags.empty?

    mapper.data = nil unless validate_tags(mapper.data.person.tags)
    mapper
  end

  def validate_tags(tags)
    tags.any? { |t| AdminUser.current_admin_user.can_manage_tag?(t) }
  end

  def resource
    resource = super

    unless (tags = AdminUser.current_admin_user&.active_tags)
      return resource
    end

    return resource if tags.empty?

    return nil unless Person.all.include?(resource.person)

    resource
  end

  def collection
    collection = super

    unless (tags = AdminUser.current_admin_user&.active_tags)
      return collection
    end

    return collection if tags.empty?

    collection.where(person: Person.all)
  end
end
