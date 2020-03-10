class Api::PersonTaggingsController < Api::EntityController
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
