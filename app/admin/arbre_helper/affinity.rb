module ArbreHelpers
  class Affinity
    def self.affinity_card(context, affinity, detailed_affinity:)
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

        if Settings.features.affinity_summary && detailed_affinity
          row(:summary) do
            related_person = to || affinity.unscoped_related_one(source)
            ::ArbreHelpers::Affinity.render_affinity_information(context, related_person, related_person)
          end
        end
      end
    end

    # In order to avoid an endless loop of affinities, the origin_person param is the root of the affinity tree that starts rendering
    # its affinities. It's used as a mark to avoid rendering more than once that resource.
    def self.render_affinity_information(context, related_person, origin_person)
      case related_person.person_type
      when :natural_person
        ::ArbreHelpers::Affinity.render_affinity_summmary_for_person(context, related_person)
      when :legal_entity
        ::ArbreHelpers::Affinity.render_affinity_summmary_for_person(context, related_person)
        unless related_person.whitelabeler?
          legal_entity_affinity_people = related_person
                                           .all_affinities
                                           .map { |related_person_affinity| related_person_affinity.unscoped_related_one(related_person) }
                                           .select { |relevant_person| relevant_person != related_person || relevant_person != origin_person }

          if legal_entity_affinity_people.any?
            span do
              strong do
                "#{related_person.related_name} Affinities"
              end
            end
            br
          end

          legal_entity_affinity_people.each do |related_person_affinity|
            ::ArbreHelpers::Affinity.render_affinity_information(context, related_person_affinity, origin_person)
          end
        end
      else
        nil
      end
    end

    def self.render_affinity_summmary_for_person(context, related_person)
      context.instance_eval do
        span do
          strong do
            related_person.related_name
          end
        end
        br

        ArbreHelpers::Affinity.affinity_summary(context, related_person.natural_dockets.last, blacklisted_attrs: %w(expected_investment), include_attachments: true)
        ArbreHelpers::Affinity.affinity_summary(context, related_person.legal_entity_dockets.last, include_attachments: true)
        ArbreHelpers::Affinity.affinity_summary(context, related_person.identifications.last, include_attachments: true)
        ArbreHelpers::Affinity.affinity_summary(context, related_person.argentina_invoicing_details.last, include_attachments: true)
        ArbreHelpers::Affinity.affinity_summary(context, related_person.domiciles.last, include_attachments: true)
        ArbreHelpers::Affinity.affinity_summary(context, related_person.risk_scores.find { |rs| rs.provider == 'worldcheck' }, include_attachments: true)
        ArbreHelpers::Affinity.affinity_summary(context, related_person.emails, only_attrs: %w(address))
        ArbreHelpers::Affinity.affinity_summary(context, related_person.phones, only_attrs: %w(number phone_kind country))
        ArbreHelpers::Affinity.affinity_summary(context, related_person.allowances.last, only_attrs: %w(), include_attachments: true)
      end
    end

    def self.affinity_summary(context, fruits_or_fruit, blacklisted_attrs: [], only_attrs: nil, include_attachments: false)
      context.instance_eval do
        return if fruits_or_fruit.blank?

        fruits_or_fruit_to_a = Array(fruits_or_fruit)
        fruits_or_fruit_to_a.each_with_index do |fruit, idx|
          columns = only_attrs || (::ArbreHelpers::Fruit.relevant_columns_for_fruit(fruit) - blacklisted_attrs)
          attachments = if include_attachments
                          # We have to use unscoped here to skip PersonScopeable.
                          ::Attachment.unscoped.where(attached_to_fruit: fruit, person_id: fruit.person_id)
                        else
                          []
                        end

          span do
            suffix = fruits_or_fruit_to_a.size > 1 ? "##{idx}" : ""
            strong "#{fruit.class.model_name.human}#{suffix}"
          end

          if columns.empty? && attachments.empty?
            br
            span do
              strong "Empty"
            end
          end

          ul do
            columns.each do |column|
              value = fruit.public_send(column)
              li "#{fruit.class.human_attribute_name(column)}: #{value}" if value.present? || value.is_a?(TrueClass) || value.is_a?(FalseClass)
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
