FactoryBot.define_persons_item_and_seed(:argentina_invoicing_detail,
  full_argentina_invoicing_detail: proc {
   vat_status_code { 'monotributo' }
   tax_id { '20955754290' }
   tax_id_kind_code { 'cuit' }
   receipt_kind_code { 'a' }
   full_name { 'Julio Iglesias' }
   address { 'Jujuy 3421' }
   country { 'AR' }
   transient{ add_all_attachments { true }}
  },
  alt_full_argentina_invoicing_detail: proc {
   vat_status_code { 'inscripto' }
   tax_id { '95575429' }
   tax_id_kind_code { 'dni' }
   receipt_kind_code { 'b' }
   full_name { 'Julio Iglesias Jr' }
   address { 'Jujuy 1234, CABA' }
   country { 'ES' }
   transient{ add_all_attachments { true }}
  }
)
