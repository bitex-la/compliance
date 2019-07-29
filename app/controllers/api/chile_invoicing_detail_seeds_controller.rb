class Api::ChileInvoicingDetailSeedsController < Api::SeedController
  def resource_class
    ChileInvoicingDetailSeed
  end

  protected

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
        :attachments,
        :copy_attachments,
        :replaces,
        :issue,
        :expires_at,
        :observations
      ]
  end
end
