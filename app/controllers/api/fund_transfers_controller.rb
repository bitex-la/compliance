class Api::FundTransfersController < Api::EntityController
  def resource_class
    FundTransfer
  end

  protected

  def related_person
    resource.source_person_id
  end

  def get_mapper
    JsonapiMapper.doc_unsafe!(params.permit!.to_h,
      %w(fund_transfers people),
      people: [],
      fund_transfers: [
        :amount,
        :exchange_rate_adjusted_amount,
        :currency_code,
        :transfer_date,
        :attachments,
        :external_id,
        :source_person,
        :target_person
      ]
    )
  end
end
