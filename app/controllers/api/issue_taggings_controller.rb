class Api::IssueTaggingsController < Api::EntityController
  def resource_class
    IssueTagging
  end

  def options_for_response
    { include: [] }
  end

  protected

  def get_mapper
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:issues, :tags, :issue_taggings],
      issues: [],
      tags: [],
      issue_taggings: [
        :tag,
        :issue
      ]
  end
end
