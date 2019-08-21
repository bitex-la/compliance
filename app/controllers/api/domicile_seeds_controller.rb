class Api::DomicileSeedsController < Api::EntityController
  def resource_class
    DomicileSeed
  end

  def get_mapper
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:issues, :domiciles, :domicile_seeds],
      issues: [],
      domiciles: [],
      domicile_seeds: [
        :country,
        :state,
        :city,
        :street_address,
        :street_number,
        :postal_code,
        :floor,
        :apartment,
        :copy_attachments,
        :replaces,
        :issue,
        :expires_at
      ]
  end
end
