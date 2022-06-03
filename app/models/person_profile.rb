# frozen_string_literal: true

class PersonProfile
  class PdfGenerator
    Prawn::Font::AFM.hide_m17n_warning = true
    attr_accessor :person, :include_affinities, :include_risk_scores

    def initialize(person, include_affinities, include_risk_scores)
      self.person = person
      self.include_affinities = include_affinities
      self.include_risk_scores = include_risk_scores
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
      if person.public_notes.empty?
        pdf.text("No data available", size: 12)
        pdf.move_down 10
        return
      end

      person.public_notes.each do |n|
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
        pdf.font_families.update(
          "Helvetica" => {
            :normal => Rails.root.join("app/assets/fonts/Helvetica.ttf")
          }
        )

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

        if include_affinities
          pdf.text("Affinities", styles: [:bold], size: 18)
          render_affinities(pdf, person)
        end

        if include_risk_scores
          pdf.text("Risk Scores", styles: [:bold], size: 18)
          render_risk_scores(pdf, person)
        end

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

  def self.generate_pdf(person, include_affinities, include_risk_scores)
    PdfGenerator.new(person, include_affinities, include_risk_scores).generate
  end

  class CsvGenerator
    HAS_MANY = Issue::HAS_MANY - [:note_seeds, :affinity_seeds, :risk_score_seeds]
    HAS_MANY_SINGULARIZED = HAS_MANY.map(&:to_s).map(&:singularize).map(&:to_sym)
    FAKE_ISSUE_ATTRS = Issue::HAS_ONE + HAS_MANY_SINGULARIZED
    ATTRS_MAPPING = FAKE_ISSUE_ATTRS.map do |r|
      serializer = Garden::Naming.new(r).serializer.constantize
      attrs = serializer.attributes_to_serialize.keys - [:archived_at, :created_at, :updated_at]
      [r, attrs]
    end.to_h
    FakeIssue = Struct.new(:raw_issue, :created_at, *FAKE_ISSUE_ATTRS, keyword_init: true)

    def self.generate_profile_history_for(person)
      fissues = []
      person.issues.find_each do |issue|
        singularized_attrs = singularize_attrs(issue, 0)
        attrs = Issue::HAS_ONE.map { |r| [r, issue.send(r)] }.to_h.merge(singularized_attrs)
        fissues << FakeIssue.new(raw_issue: issue, created_at: issue.created_at, **attrs)
        extra_relations = HAS_MANY.map { |r| issue.send(r).count }.max - 1
        extra_relations.times.map do |idx|
          wanted_idx = idx + 1
          fissues << FakeIssue.new(raw_issue: issue, created_at: issue.created_at, **singularize_attrs(issue, wanted_idx))
        end
      end

      basic_headers = %i[person_id issue_id created_at reason issue_state person_state]
      headers = [*basic_headers]
      ATTRS_MAPPING.each do |r, attrs|
        attrs.each { |a| headers << "#{Garden::Naming.new(r).base}-#{a}" }
      end

      rows = [headers]
      event_kinds = [:person_enabled, :person_disabled, :person_rejected].map { |v| EventLogKind.send(v) }
      events = person.event_logs.where(verb_id: event_kinds).to_a
      things = (events + fissues).sort_by(&:created_at)
      things.each do |thing|
        row_kv = basic_headers.map { |k| [k, nil] }.to_h
        row_data = []
        if thing.is_a? FakeIssue
          issue = thing
          raw_issue = issue.raw_issue
          row_kv.update(person_id: raw_issue.person_id, issue_id: raw_issue.id,
                        reason: raw_issue.reason.to_s, created_at: raw_issue.created_at,
                        issue_state: raw_issue.state)
          ATTRS_MAPPING.map do |r, attrs|
            seed = issue.send(r)
            attrs.each { |a| row_data << seed.try(a) }
          end

          next if row_data.compact.empty?
        else
          event = thing
          row_kv.update(person_id: event.entity_id, created_at: event.created_at, person_state: event.verb.code)
        end

        rows << [*row_kv.values, *row_data]
      end

      rows.map(&:to_csv).join
    end

    def self.generate_observations_history_for(person)
      headers = %i[person_id issue_id created_at replied_on state reason body note reply]
      rows = [headers]
      Observation.client.eager_load(:observation_reason).where(issue: person.issues).each do |obs|
        rows << [person.id, obs.issue_id, obs.created_at, obs.updated_at, obs.state,
                 obs.observation_reason.subject_es, obs.observation_reason.body_es, obs.note,
                 obs.reply]
      end
      rows.map(&:to_csv).join
    end

    def self.singularize_attrs(issue, idx)
      [HAS_MANY_SINGULARIZED, HAS_MANY].transpose.map { |s, p| [s, issue.send(p)[idx]] }.to_h
    end
  end
end
