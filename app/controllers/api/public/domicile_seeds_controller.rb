class Api::Public::DomicileSeedsController < Api::Public::SeedController
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
        :attachments,
        :copy_attachments,
        :replaces,
        :issue
      ]
  end
end
