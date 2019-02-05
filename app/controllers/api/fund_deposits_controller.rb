class Api::FundDepositsController < Api::EntityController
  def resource_class
    FundDeposit
  end

  protected

  def get_mapper
    JsonapiMapper.doc_unsafe!(params.permit!.to_h,
      %w(fund_deposits people attachments),
      people: [],
      fund_deposits: [
        :amount,
        :currency_code,
        :deposit_method_code,
        :external_id,
        :attachments,
        :person
      ],
      attachments: [
        :document,
        :document_file_name,
        :document_content_type,
      ]
    )
  end
end
