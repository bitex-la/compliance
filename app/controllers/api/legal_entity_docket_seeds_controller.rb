class Api::LegalEntityDocketSeedsController < Api::EntityController
  def resource_class
    LegalEntityDocketSeed
  end

  protected

  def related_person
    resource.issue.person_id
  end

  def get_mapper
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:issues, :legal_entity_dockets, :legal_entity_docket_seeds],
      issues: [],
      legal_entity_dockets: [],
      legal_entity_docket_seeds: [
        :industry,
        :business_description,
        :country,
        :commercial_name,
        :legal_name,
        :copy_attachments,
        :issue,
        :expires_at,
        :archived_at,
        :regulated_entity,
        :operations_with_third_party_funds
      ]
  end
end
