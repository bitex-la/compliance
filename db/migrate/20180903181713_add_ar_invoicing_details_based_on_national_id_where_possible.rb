class AddArInvoicingDetailsBasedOnNationalIdWherePossible < ActiveRecord::Migration[5.1]
  def up
    query = Person.joins(:identifications)
      .includes(:argentina_invoicing_details, :legal_entity_dockets)
      .where(
        legal_entity_dockets: {id: nil},
        identifications: {issuer: 'AR', identification_kind_id: 7},
        argentina_invoicing_details: {id: nil})

    puts "Going to add #{query.count} Argentina Invoicing Details"
    
    query.each do |person|
      ids = person.identifications
      id_to_use = ids.where(identification_kind_id: IdentificationKind.national_id.id).first ||
        ids.where(identification_kind_id: IdentificationKind.tax_id.id).first

      next unless id_to_use
      puts "Adding for #{person.id}"

      tax_id_kind, vat_status = if id_to_use.identification_kind == IdentificationKind.national_id 
        [TaxIdKind.dni, VatStatusKind.consumidor_final]
      else
        [TaxIdKind.cuit, VatStatusKind.monotributo]
      end

      docket = person.natural_docket
      full_name = "#{docket.try(:first_name)} #{docket.try(:last_name)}"
      domicile = person.domiciles.where(country: 'AR').first
      address = if domicile 
        "#{domicile.city}, #{domicile.street_address}, #{domicile.street_number}"
      end

      detail = person.argentina_invoicing_details.create!(
        vat_status: vat_status,
        tax_id: id_to_use.number,
        person: person,
        tax_id_kind: tax_id_kind,
        receipt_kind: ReceiptKind.b,
        full_name: full_name,
        country: 'AR',
        address: address
      )
      person.notes.create!(
        person: person,
        body: "argentina_invoicing_detail added by migration. ID##{detail.id}",
        title: "20180903154827_add_argentina_invoicing_details_where_possible")
    end
  end

  def down
  end
end
