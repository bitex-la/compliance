class Api::ChileInvoicingDetailSeedsController < Api::EntityController
  def resource_class
    ChileInvoicingDetailSeed
  end

  protected

  def related_person
    resource.issue.person_id
  end

  def get_mapper
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:issues, :chile_invoicing_details, :chile_invoicing_detail_seeds],
      issues: [],
      chile_invoicing_details: [],
      chile_invoicing_detail_seeds: [
        :vat_status_code,
        :tax_id,
        :giro,
        :ciudad,
        :comuna,
        :copy_attachments,
        :replaces,
        :issue,
        :expires_at,
        :archived_at
      ]
  end
end
