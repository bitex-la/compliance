class Api::Public::NoteSeedsController < Api::Public::SeedController
  def resource_class
    NoteSeed.where(private: false)
  end

  protected

  def get_mapper
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:issues, :note_seeds],
      issues: [],
      note_seeds: [
        :title,
        :body,
        :attachments,
        :copy_attachments,
        :replaces,
        :issue
      ]
  end
end
