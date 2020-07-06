class Api::NaturalDocketSeedsController < Api::EntityController
  def resource_class
    NaturalDocketSeed
  end

  def create
    mapper = get_mapper
    return jsonapi_422 unless mapper.data

    mapper.data.remote_ip = request.env['REMOTE_ADDR']
    if mapper.data.save
      jsonapi_response mapper.data, options_for_response, 201
    else
      json_response mapper.all_errors, 422
    end
  end

  protected

  def related_person
    resource.issue.person_id
  end

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
        :copy_attachments,
        :issue,
        :expires_at,
        :archived_at
      ]
  end
end
