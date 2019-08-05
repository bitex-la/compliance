module ArbreHelpers
  class Seed
    def self.seed_collection_and_fruits_show_tab(context, icon, seed, fruits_relation, text=nil)
      context.instance_eval do
        ArbreHelpers::Seed.seed_collection_and_fruits_edit_tab(context, icon, seed, fruits_relation, text) do
          h3 "Current Seeds"
          seed_relation = seed.naming.seed_plural
          items = resource.try(seed_relation) || resource.try(seed_relation.singularize)
          all = items.try(:count) ? items : [items].compact
          if all.any?
            ArbreHelpers::Layout.panel_only(self, all) do |d|
              ArbreHelpers::Seed.seed_show_section(self, d)
            end
          else
            ArbreHelpers::Layout.alert(self, "No items available", "info")
          end
        end
      end
    end

    def self.show_full_seed(context, seed, fruits_relation, &block)
      context.instance_eval do
        columns do
          column span: 2 do
            instance_exec &block
          end
          column do
            ArbreHelpers::Fruit.current_fruits_panel(self, fruits_relation)
            ArbreHelpers::Seed.others_seeds_panel(self, seed)
          end
        end
      end
    end

    def self.seed_collection_and_fruits_edit_tab(context, icon, seed, fruits_relation, text=nil, &block)
      context.instance_eval do
        seed_relation = seed.naming.seed_plural
        items = resource.try(seed_relation) || resource.try(seed_relation.singularize)
        all = items.try(:count) ? items : [items].compact
        ArbreHelpers::Layout.tab_with_counter_for(self, seed.naming.plural.humanize, all.count, icon, text) do
          ArbreHelpers::Seed.show_full_seed(self, seed, fruits_relation, &block)
        end
      end
    end

    def self.seed_show_section(context, seed, others = [])
      context.instance_eval do
        ArbreHelpers::Seed.seed_attributes_table self, seed, others
        if seed.respond_to?(:external_link) && !seed.external_link.blank?
          h4 "External links"
          ArbreHelpers::HtmlHelper.show_links(self, seed.external_link.split(',').compact)
        end
        if seed.respond_to? :extra_info 
          h4 "Extra info"
          begin 
            if seed.extra_info
              extra_info_as_json = JSON.parse(seed.extra_info)
              ArbreHelpers::HtmlHelper.extra_info_renderer(self, extra_info_as_json)
            end
          rescue JSON::ParserError
            span seed.extra_info
          end
        end
        
        h4 "Observations"
        ArbreHelpers::Observation.show_observations(self, seed.observations, true)

        h4 "Attachments"
        attachments = seed.fruit ? seed.fruit.attachments : seed.attachments
        if attachments.any?
          attachments.each do |a|
            ArbreHelpers::Attachment.preview(self, a)
          end
        else
          ArbreHelpers::Layout.alert(self, "No items available", "info")
        end
      end
    end

    def self.seed_attributes_table(context, resource, others = [])
      columns = resource.class.columns.map(&:name) - others.map(&:to_s)
      columns = columns.map{|c| c.gsub(/_id$/,'') } -
        %w(id issue fruit created_at updated_at replaces copy_attachments extra_info external_link)

      context.instance_eval do
        attributes_table_for resource, :fruit, *columns, *others
      end
    end

    def self.others_seeds_panel(context, relation, extra = [])
      context.instance_eval do
        h3 "Other Seeds"
        seeds = relation.others_active_seeds(resource)
        if seeds.any?
          ArbreHelpers::Layout.panel_only(self, seeds) do |s|
            ArbreHelpers::Seed.seed_show_section(self, s, [:issue] + extra)
          end
        else
          ArbreHelpers::Layout.alert(self, "No items available", "info")
        end
      end
    end
  end
end
