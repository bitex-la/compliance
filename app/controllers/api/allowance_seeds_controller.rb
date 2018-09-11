class Api::AllowanceSeedsController < Api::SeedController
  def resource_class
    AllowanceSeed
  end

  protected 
  
  def get_mapper
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:issues, :allowance_seeds, :allowances],
      issues: [],
      allowances: [],
      allowance_seeds: [
        :weight,
        :amount,
        :kind_code,
        :attachments,
        :copy_attachments,
        :replaces,
        :issue
      ]
  end
end
