class Api::TagsController < Api::EntityController
  def resource_class
    Tag
  end

  protected

  def get_mapper
    JsonapiMapper.doc_unsafe!(params.permit!.to_h,
      %w(tags),
      tags: [
        :name,
        :tag_type
      ]
    )
  end

  private

  def allow_restricted_user
    false
  end
end
