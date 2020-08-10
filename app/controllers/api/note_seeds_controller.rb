class Api::NoteSeedsController < Api::EntityController
  def resource_class
    NoteSeed
  end

  protected

  def related_person
    resource.issue.person_id
  end

  def get_mapper
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:issues, :notes, :note_seeds],
      issues: [],
      notes: [],
      note_seeds: [
        :title,
        :body,
        :copy_attachments,
        :replaces,
        :issue,
        :expires_at,
        :archived_at
      ]
  end
end
