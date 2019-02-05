class Api::NaturalDocketSeedsController < Api::EntityController
  def resource_class
    NaturalDocketSeed
  end

  protected

  def get_mapper
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:issues, :natural_dockets, :natural_docket_seeds],
      issues: [],
      natural_dockets: [],
      natural_docket_seeds: [
        :first_name,
        :last_name,
        :birth_date,
        :nationality,
        :gender_code,
        :marital_status_code,
        :job_title,
        :job_description,
        :politically_exposed,
        :politically_exposed_reason,
        :attachments,
        :copy_attachments,
        :issue
      ]
  end
end
