class Api::AttachmentsController < Api::SeedController
  def resource_class
    Attachments
  end

  def options_for_response
    { include: [] }
  end

  protected

  def get_mapper
    can_attach_to = %i(domicile_seeds phone_seeds email_seeds note_seeds
      affinity_seeds identification_seeds natural_docket_seeds
      risk_score_seeds legal_entity_docket_seeds allowance_seeds
      argentina_invoicing_detail_seeds chile_invoicing_detail_seeds
    )
    
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      ([:people, :attachments] + can_attach_to),
      can_attach_to.map{|a| [a, []]}.to_h.merge(
        attachments: [
          :document,
          :document_file_name,
          :document_file_size,
          :document_content_type,
          :attached_to_seed,
          :attached_to_seed_id,
          :attached_to_seed_type,
          :person
        ]
      )
  end
end
