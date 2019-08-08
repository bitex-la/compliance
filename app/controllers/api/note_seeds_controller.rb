class Api::NoteSeedsController < Api::SeedController
  def resource_class
    NoteSeed
  end

  protected

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
        :expires_at
      ]
  end
end
