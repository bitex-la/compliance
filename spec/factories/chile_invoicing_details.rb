FactoryBot.define_persons_item_and_seed(:chile_invoicing_detail,
  full_chile_invoicing_detail: proc {
   tax_id { '10569670-1' }
   giro { 'Venta de Cosas' }
   ciudad { 'Santiago' }
   comuna { 'Santiago' }
   vat_status_code { 'inscripto' }
   transient{ add_all_attachments { true }}
  },
  alt_full_chile_invoicing_detail: proc {
   tax_id { '22435725-7' }
   giro { 'Compra de Cosas' }
   ciudad { 'Panguipulli' }
   comuna { 'Huilo Huilo' }
   vat_status_code { 'consumidor_final' }
   transient{ add_all_attachments { true }}
  }
)
