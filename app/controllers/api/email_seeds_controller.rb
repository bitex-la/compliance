class Api::EmailSeedsController < Api::SeedController
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
        :issue
      ]
  end
end
