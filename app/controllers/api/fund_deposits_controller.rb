class Api::FundDepositsController < Api::ApiController
  def create
    map_and_save(201, params[:person_id])
  end

  def show 
    person = Person.find(params[:person_id])
    jsonapi_response person.fund_deposits.find(params[:id]), {}
  end

  def update
    person = Person.find(params[:person_id])
    map_and_save(200, params[:person_id], params[:id])
  end

  def map_and_save(success_code, person_id, deposit_id = nil)
    mapper = get_mapper(person_id, deposit_id)
    return jsonapi_422(nil) unless mapper.data

    if mapper.save_all
      jsonapi_response mapper.data, {}, success_code
    else
      json_response mapper.all_errors, 422
    end
  end

  def get_mapper(person_id, deposit_id = nil)
    mapper = JsonapiMapper.doc_unsafe!(params.permit!.to_h,
      %w(fund_deposits people attachments),
      fund_deposits:[
        :amount,
        :currency_code,
        :deposit_method_code,
        :external_id,
        :attachments,
        id: deposit_id,
        person_id: person_id
      ],
      attachments: [
        :document,
        :document_file_name,
        :document_content_type,
        person_id: person_id
      ],
      people: []
    )
    
    mapper
  end
end