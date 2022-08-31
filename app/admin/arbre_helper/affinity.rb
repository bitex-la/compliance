module ArbreHelpers
  class Affinity
    def self.affinity_card(context, affinity)
      context.instance_eval do
        source = self.resource.try(:person) || self.resource
        from = source
        to = affinity.related_one(source)
        read_unscoped_affinity = false

        row(:person) do
          link_to from.name, from
        end
        row(:related_person) do
          if to
            link_to to.name, to
          else
            read_unscoped_affinity = true
            affinity.unscoped_related_one(source).related_name
          end
        end

        row(:affinity_kind) do
          affinity.unscoped_get_label(self.resource)
        end
        row(:created_at)
        row(:issue) unless read_unscoped_affinity

        if Settings.features.affinity_summary
          row(:summary) do
            related_person = to || affinity.unscoped_related_one(source)
            ArbreHelpers::Affinity.affinity_summary(context, related_person.natural_dockets.last,blacklisted_attrs: %w(expected_investment politically_exposed politically_exposed_reason), include_attachments: true)
            ArbreHelpers::Affinity.affinity_summary(context, related_person.legal_entity_dockets.last, blacklisted_attrs: %w(regulated_entity operations_with_third_party_funds), include_attachments: true)
            ArbreHelpers::Affinity.affinity_summary(context, related_person.identifications.last, include_attachments: true)
            # FIXME: We have to specify the attributes for ArgentinaInvoicingDetails given that tax_id column is wrongly called by ::ArbreHelpers::Fruit.relevant_columns_for_fruit(fruit)
            ArbreHelpers::Affinity.affinity_summary(context, related_person.argentina_invoicing_details.last, include_attachments: true, only_attrs: %w(vat_status tax_id tax_id_kind receipt_kind full_name address country))
            ArbreHelpers::Affinity.affinity_summary(context, related_person.domiciles.last, include_attachments: true)
            ArbreHelpers::Affinity.affinity_summary(context, related_person.risk_scores.find { |rs| rs.provider == 'worldcheck' }, include_attachments: true)
            ArbreHelpers::Affinity.affinity_summary(context, related_person.emails, only_attrs: %w(address))
            ArbreHelpers::Affinity.affinity_summary(context, related_person.phones, only_attrs: %w(number phone_kind country))
            ArbreHelpers::Affinity.affinity_summary(context, related_person.allowances.last, only_attrs: %w(), include_attachments: true)
          end
        end
      end
    end

    def self.affinity_summary(context, fruits_or_fruit, blacklisted_attrs: [], only_attrs: nil, include_attachments: false)
      context.instance_eval do
        return if fruits_or_fruit.blank?

        fruits_or_fruit_to_a = Array(fruits_or_fruit)
        fruits_or_fruit_to_a.each_with_index do |fruit, idx|
          suffix = fruits_or_fruit_to_a.size > 1 ? "##{idx}" : ""
          span do
            strong "#{fruit.class.model_name.human}#{suffix}"
          end
          columns = only_attrs || (::ArbreHelpers::Fruit.relevant_columns_for_fruit(fruit) - blacklisted_attrs)
          attachments = include_attachments ? fruit.attachments : []

          if columns.empty? || attachments.empty?
            span do
              strong "Empty"
            end
          end
          ul do
            columns.each do |column|
              value = fruit.public_send(column)
              next if value.blank?
              li "#{fruit.class.human_attribute_name(column)}: #{value}"
            end
            if include_attachments
              attachments.map do |attachment|
                li do
                  link_to attachment.document_file_name, attachment.document_url
                end
              end
            end
          end
        end

        # This returns nil on purpose because ActiveAdmin will try to render something out if its an
        # ActiveRecord::Base or ActiveRecord::Relation
        nil
      end
    end
  end
end
