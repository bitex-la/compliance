class Api::AllowanceSeedsController < Api::EntityController
  def resource_class
    AllowanceSeed
  end

  protected 

  def related_person
    resource.issue.person_id
  end
  
  def get_mapper
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:issues, :allowance_seeds, :allowances],
      issues: [],
      allowances: [],
      allowance_seeds: [
        :weight,
        :amount,
        :kind_code,
        :copy_attachments,
        :replaces,
        :issue,
        :expires_at,
        :archived_at
      ]
  end
end
