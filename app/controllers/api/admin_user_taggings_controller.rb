class Api::AdminUserTaggingsController < Api::EntityController
  def resource_class
    AdminUserTagging
  end

  def options_for_response
    { include: [] }
  end

  protected

  def get_mapper
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:admin_users, :tags, :admin_user_taggings],
      admin_users: [],
      tags: [],
      admin_user_taggings: [
        :tag,
        :admin_user
      ]
  end
end
