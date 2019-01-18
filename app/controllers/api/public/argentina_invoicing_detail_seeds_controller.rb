class Api::Public::ArgentinaInvoicingDetailSeedsController < Api::Public::SeedController
  def resource_class
    ArgentinaInvoicingDetailSeed
  end

  protected

  def get_mapper
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:issues, :argentina_invoicing_details, :argentina_invoicing_detail_seeds],
      issues: [],
      argentina_invoicing_details: [],
      argentina_invoicing_detail_seeds: [
        :vat_status_code,
        :tax_id,
        :tax_id_kind_code,
        :receipt_kind_code,
        :full_name,
        :country,
        :address,
        :attachments,
        :copy_attachments,
        :replaces,
        :issue
      ]
  end
end
