class Api::EmailSeedsController < Api::EntityController
  def resource_class
    EmailSeed
  end

  protected

  def get_mapper
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:issues, :emails, :email_seeds],
      issues: [],
      emails: [],
      email_seeds: [
        :address,
        :email_kind_code,
        :attachments,
        :copy_attachments,
        :replaces,
        :issue,
        :expires_at
      ]
  end
end
