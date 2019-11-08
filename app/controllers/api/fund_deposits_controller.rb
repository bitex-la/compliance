class Api::FundDepositsController < Api::EntityController
  def resource_class
    FundDeposit
  end

  protected

  def related_person
    resource.person_id
  end

  def get_mapper
    JsonapiMapper.doc_unsafe!(params.permit!.to_h,
      %w(fund_deposits people),
      people: [],
      fund_deposits: [
        :amount,
        :exchange_rate_adjusted_amount,
        :currency_code,
        :deposit_method_code,
        :external_id,
        :attachments,
        :person
      ]
    )
  end
end
