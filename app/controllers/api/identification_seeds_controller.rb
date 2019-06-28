class Api::IdentificationSeedsController < Api::SeedController
  def resource_class
    IdentificationSeed
  end

  protected

  def get_mapper
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:issues, :identifications, :identification_seeds],
      issues: [],
      identifications: [],
      identification_seeds: [
        :identification_kind_code,
        :number,
        :issuer,
        :attachments,
        :copy_attachments,
        :replaces,
        :issue,
        :expires_at
      ]
  end
end
