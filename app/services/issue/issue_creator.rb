class Issue::IssueCreator
  def self.call(attributes)
    issue = nil
    errors = []
    
    begin
      mapper = map_out(attributes)
      if mapper.all_valid?
        mapper.save_all
        issue = Issue.last
      else
        errors = mapper.all_errors
      end     
    rescue ActiveRecord::RecordNotFound
      errors << JsonApi::Error.new({
        links:   {},
        status:  404,
        code:    "person_not_found",
        title:  "person not found",
        detail: "person_not_found",
        source: { "pointer": "/data/attributes/person" },
        meta:   {}
      })  
    end  
    [issue, errors]
  end
  
  private
  
  def self.map_out(attributes)
    person_scope = look_scope_by_id(attributes[:data][:relationships][:person])

    JsonapiMapper.doc(attributes, 
      issue: [:person, 
        :domicile_seeds, 
        :identification_seeds, 
        :natural_docket_seeds,
        :legal_entity_docket_seeds,
        :quota_seeds,
        id: ''
      ],
      person: [id: person_scope],
      domicile_seed: [
        :country,
        :state,
        :city,
        :street_address,
        :street_number,
        :postal_code,
        :floor,
        :apartment,
        :attachments,
        id: ''
      ],
      identification_seed: [
        :kind,
        :number,
        :issuer,
        :attachments,
        id: '',
      ],
      natural_docket_seed: [
        :first_name,
        :last_name,
        :birth_date,
        :nationality,
        :gender,
        :marital_status,
        :attachments,
        id: ''
      ],
      legal_entity_docket_seed: [
        :industry,
        :business_description,
        :country,
        :commercial_name,
        :legal_name,
        :attachments,
        id: ''
      ],
      quota_seed: [
        :weight,
        :amount,
        :kind,
        :attachments,
        id: ''
      ],
      attachment: [
        :person,
        :document,
        :document_file_name,
        :document_content_type,
        id: ''
      ]
    )
  end 

  def self.look_scope_by_id(object)
    return '' if object.nil?
    object[:data][:id].to_s.start_with?('@') ? '' : object[:data][:id]
  end
end