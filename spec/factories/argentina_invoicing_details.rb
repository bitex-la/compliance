FactoryBot.define_persons_item_and_seed(:argentina_invoicing_detail,
  full_argentina_invoicing_detail: proc {
   vat_status_id { 2 }
   tax_id { '20955754290' }
   tax_id_kind_id { 80 }
   receipt_kind_id { 1 }
   full_name { "Julio Iglesias" }
   address { "Jujuy 3421" }
   country { "AR" }
   transient{ add_all_attachments { true }}
  }
)
