# frozen_string_literal: true

class PersonProfile
  class PdfGenerator
    Prawn::Font::AFM.hide_m17n_warning = true
    attr_accessor :person

    def initialize(person)
      self.person = person
    end

    def nice_table(pdf, rows, headings: [], totals: [])
      pdf.table(
        [headings.map { |i|
            attrs = { font_style: :bold }
            i.is_a?(Hash) ? i.merge(attrs) : attrs.merge(content: i)
          },
           * rows,
          totals.map{ |i|
            attrs = {
              background_color: "CCCCCC",
              border_width: 0,
            }
            i.is_a?(Hash) ? i.merge(attrs) : attrs.merge(content: i)
          },
        ].compact,
        width: pdf.bounds.width,
        cell_style: {
          borders: [:bottom],
          border_lines: [:dotted],
          padding: 2
        }
      )
      pdf.move_down 20
    end

    def render_identifications(pdf, person)
      if person.identifications.empty?
        pdf.text("No data available", size: 12)
        pdf.move_down 10
        return
      end

      person.identifications.each do |i|
        nice_table(pdf, [
          ["Kind: #{i.identification_kind}", "Number: #{i.number}", "Issuer: #{i.issuer}"],
          ["Public Registry Authority: #{i.public_registry_authority}", "Public Registry Book: #{i.public_registry_book}", "Public Registry Data: #{i.public_registry_extra_data}"]
          ]
        )
      end
    end

    def render_docket(pdf, person)
      case person.person_type
      when :natural_person
        docket = person.natural_dockets.last
        nice_table(pdf, [
          ["First Name: #{docket.first_name}", "Last Name: #{docket.last_name}", "Birth Date: #{docket.birth_date}"],
          ["Nationality: #{docket.nationality}", "Gender: #{docket.gender}", "Marital Status: #{docket.marital_status}"],
          ["Job Title: #{docket.job_title}", "Job Description: #{docket.job_description}"],
          ["PEP: #{docket.politically_exposed}", "PEP Reason: #{docket.politically_exposed_reason}"]
          ]
        )
      when :legal_entity
        docket = person.legal_entity_dockets.last
        nice_table(pdf, [
          ["Legal Name: #{docket.legal_name}", "Industry: #{docket.industry}", "Business: #{docket.business_description}"],
          ["Country: #{docket.country}", "Commercial Name: #{docket.commercial_name}"]
          ]
        )
      else
        pdf.text("No data available", size: 12)
        pdf.move_down 10
      end
    end

    def render_invoices(pdf, person)
      if person.argentina_invoicing_details.empty? && person.chile_invoicing_details.empty?
        pdf.text("No data available", size: 12)
        pdf.move_down 10
        return
      end

      person.argentina_invoicing_details.each do |i|
        nice_table(pdf, [
          ["Vat Status: #{i.vat_status}", "Tax Id: #{i.tax_id}", "Tax Id Kind: #{i.tax_id_kind}"],
          ["Receipt Kind: #{i.receipt_kind}", "Full Name: #{i.full_name}"],
          ["Address: #{i.address}", "Country: #{i.country}"]
          ]
        )
      end

      person.chile_invoicing_details.each do |i|
        nice_table(pdf, [
          ["Giro: #{i.giro}", "Tax Id: #{i.tax_id}", "Ciudad: #{i.ciudad}"],
          ["Comuna: #{i.comuna}", "Vat Status Id: #{i.vat_status}"]
          ]
        )
      end
    end

    def render_phones(pdf, person)
      if person.phones.empty?
        pdf.text("No data available", size: 12)
        pdf.move_down 10
        return
      end

      person.phones.each do |p|
        nice_table(pdf, [
          ["Number: #{p.number}", "Phone Kind: #{p.phone_kind}", "Country: #{p.country}"]
          ]
        )
      end
    end

    def render_mails(pdf, person)
      if person.emails.empty?
        pdf.text("No data available", size: 12)
        pdf.move_down 10
        return
      end

      person.emails.each do |e|
        nice_table(pdf, [
          ["Address: #{e.address}", "Email Kind: #{e.email_kind}"]
          ]
        )
      end
    end

    def render_domiciles(pdf, person)
      if person.domiciles.empty?
        pdf.text("No data available", size: 12)
        pdf.move_down 10
        return
      end

      person.domiciles.each do |d|
        nice_table(pdf, [
          ["Country: #{d.country}","State: #{d.state}","City: #{d.city}"],
          ["Adress: #{d.street_address}","Number: #{d.street_number}","Postal Code: #{d.postal_code}"],
          ["Floor: #{d.floor}", "Apartment: #{d.apartment}"]
          ]
        )
      end
    end

    def render_notes(pdf, person)
      if person.notes.empty?
        pdf.text("No data available", size: 12)
        pdf.move_down 10
        return
      end

      person.notes.each do |n| #TODO only public notes
        nice_table(pdf, [
          ["Number: #{n.body}"]
          ]
        )
      end
    end

    def render_affinities(pdf, person)
      if person.affinities.empty?
        pdf.text("No data available", size: 12)
        pdf.move_down 10
        return
      end

      person.affinities.each do |a|
        nice_table(pdf, [
          ["Kind: #{a.affinity_kind}"]
          ]
        )
        related = a.related_person
        pdf.text("Docket", styles: [:bold], size: 14)
        render_docket(pdf, related)
        pdf.text("Identifications", styles: [:bold], size: 14)
        render_identifications(pdf, related)
        pdf.text("Invoices", styles: [:bold], size: 14)
        render_invoices(pdf, related)
        pdf.text("Emails", styles: [:bold], size: 14)
        render_mails(pdf, related)
        pdf.text("Phones", styles: [:bold], size: 14)
        render_phones(pdf, related)
      end
    end

    def render_risk_scores(pdf, person)
      if person.risk_scores.empty?
        pdf.text("No data available", size: 12)
        pdf.move_down 10
        return
      end

      person.risk_scores.select { |r| r.provider != 'open_compliance' && r.provider != 'Scorechain' }
        .each do |r|
        nice_table(pdf, [
          ["Score: #{r.score}", "Provider: #{r.provider}"],
          ["Extra Info: #{r.extra_info}", "Created At: #{r.created_at}"],
          ["External Link: #{r.external_link}"]
          ]
        )
      end
    end

    def generate
      Prawn::Document.new(margin: 15) do |pdf|
        pdf.text "Bitex", color: "1b80c4", size: 42, align: :center

        pdf.text("Profile", styles: [:bold], size: 24)

        pdf.text("Basic Data", styles: [:bold], size: 18)

        nice_table(pdf, [["Created At: #{person.created_at.strftime("%Y-%m-%d")}",
          "Updated At: #{person.updated_at.strftime("%Y-%m-%d")}"]])

        pdf.text("Docket", styles: [:bold], size: 18)
        render_docket(pdf, person)

        pdf.text("Identifications", styles: [:bold], size: 18)
        render_identifications(pdf, person)

        pdf.text("Domiciles", styles: [:bold], size: 18)
        render_domiciles(pdf, person)

        pdf.text("Invoicing", styles: [:bold], size: 18)
        render_invoices(pdf, person)

        pdf.text("EMails", styles: [:bold], size: 18)
        render_mails(pdf, person)

        pdf.text("Phones", styles: [:bold], size: 18)
        render_phones(pdf, person)

        pdf.text("Notes", styles: [:bold], size: 18)
        render_notes(pdf, person)

        pdf.text("Affinities", styles: [:bold], size: 18)
        render_affinities(pdf, person)

        pdf.text("Risk Scores", styles: [:bold], size: 18)
        render_risk_scores(pdf, person)

        pdf.number_pages "<page>/<total>", {
          at: [pdf.bounds.right - 150, 5],
          width: 150,
          page_filter: :all,
          align: :right,
          start_count_at: 1
        }
      end
    end
  end

  def self.generate_pdf(person)
    PdfGenerator.new(person).generate
  end
end
