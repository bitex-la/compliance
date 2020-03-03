class Api::FundWithdrawalsController < Api::EntityController
  def resource_class
    FundWithdrawal
  end

  protected

  def related_person
    resource.person_id
  end

  def get_mapper
    JsonapiMapper.doc_unsafe!(params.permit!.to_h,
      %w(fund_withdrawals people),
      people: [],
      fund_withdrawals: [
        :amount,
        :exchange_rate_adjusted_amount,
        :currency_code,
        :country,
        :withdrawal_date,
        :external_id,
        :attachments,
        :person
      ]
    )
  end
end
