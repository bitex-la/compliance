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

    # if the admin users doesn't have tags return the resource
    return resource if AdminUser.current_admin_user&.active_tags&.empty?

    # return nil if the current admin user do not have permission
    # to view the resource's person
    return nil unless Person.all.include?(resource.person)

    resource
  end

  def collection
    collection = super

    # if the admin users doesn't have tags return the collection
    # without filtering
    return collection if AdminUser.current_admin_user&.active_tags&.empty?

    # filter the collection with the valid people..Person.all already filter the
    # proper tags
    collection.where(person: Person.all)
  end
end
