class Api::IdentificationSeedsController < Api::EntityController
  def resource_class
    IdentificationSeed
  end

  protected

  def related_person
    resource.issue.person_id
  end

  def get_mapper
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:issues, :identifications, :identification_seeds],
      issues: [],
      identifications: [],
      identification_seeds: [
        :identification_kind_code,
        :number,
        :issuer,
        :copy_attachments,
        :replaces,
        :issue,
        :expires_at,
        :archived_at
      ]
  end
end
