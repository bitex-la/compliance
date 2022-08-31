module ArbreHelpers
  class Fruit
    def self.fruit_show_page(context)
      context.instance_eval do
        columns do
          column span: 2 do
            ArbreHelpers::Fruit.fruit_attribute_table(self, resource)
            if resource.respond_to?(:external_link) && !resource.external_link.blank?
              h4 "External links"
              ArbreHelpers::HtmlHelper.show_links(self, resource.external_link.split(',').compact)
            end 
            if resource.respond_to?(:extra_info)  && !resource.extra_info.nil?
              h4 "Extra info"
              begin 
                if resource.extra_info
                  extra_info_as_json = JSON.parse(resource.extra_info)
                  ArbreHelpers::HtmlHelper.extra_info_renderer(self, extra_info_as_json)
                end
              rescue JSON::ParserError
                span resource.extra_info
              end
            end
            if attachments = resource.attachments.presence
              h3 "Attachments"
              ArbreHelpers::Attachment.attachments_list(self, attachments)
            end
          end

          column do 
            ArbreHelpers::Fruit.fruit_relations_panels(self, resource)
          end 
        end  
      end
    end

    def self.fruit_attribute_table(context, resource, &block)
      context.instance_eval do 
        if block
          attributes_table_for(resource, &block)
        else
          blacklist = %i(id person issue_id created_at updated_at replaced_by extra_info external_link)
          attributes_table_for(resource, *(default_attribute_table_rows - blacklist))
        end
      end
    end

    def self.fruit_relations_panels(context, resource)
      context.instance_eval do
        person = resource.person

        attributes_table_for(resource) do
          row :id
          if resource.replaced_by
            row :replaced_by
          end
          row :person
          row :issue
          row :created_at
        end

        if previous = resource.previous_versions.presence
          h3 "Previous versions"
          previous.each do |r|
            span r.created_at.strftime("%e %b %Y :")
            span link_to "#{r.name}", r
            br
          end
        end

        if others = resource.others_for_person.presence
          h3 "Other #{resource.class.name.pluralize.titleize} for person"
          others.each do |r|
            span r.created_at.strftime("%e %b %Y :")
            span link_to "#{r.name}", r
            br
          end
        end
      end
    end

    def self.fruit_collection_show_tab(context, relation, icon, extra={})
      context.instance_eval do
        text = extra[:text]
        title = extra[:title] || relation.to_s.humanize

        items = resource.send(relation)
        all = items.try(:current).try(:order, 'created_at DESC') || [items].compact
        
        ArbreHelpers::Layout.tab_with_counter_for(self, title, all.count, icon, text) do
          ArbreHelpers::Layout.panel_grid(self, all) do |d|
            ArbreHelpers::Fruit.fruit_show_section(self, d)
          end
        end
      end
    end

    def self.relevant_columns_for_fruit(fruit, others = [])
      columns = fruit.class.columns.map(&:name) - others.map(&:to_s)
      excluded_columns = %w(id person issue created_at updated_at replaces extra_info external_link)
      displayable_columns = columns.map do |c|
        # We don't want to show columns whose value is an ID. Instead, we prefer returning the object that is associated to that ID.
        # However, there are some cases where an ID is just a value, for example: "tax_id".
        # Therefore, we check if the fruit responds to the method without an id, if it does, we return it.
        method_without_id = c.gsub(/_id$/,'')
        fruit.respond_to?(method_without_id) ? method_without_id : c
      end
      displayable_columns - excluded_columns
    end

    def self.fruit_show_section(context, fruit, others = [])
      context.instance_eval do
        if fruit.class.name == "Affinity"
          attributes_table_for fruit do
            ArbreHelpers::Affinity.affinity_card(self, fruit)
          end
        else
          columns = ArbreHelpers::Fruit.relevant_columns_for_fruit(fruit, others)
          attributes_table_for fruit do
            row(:show){|o| link_to o.name, o }
            columns.each do |n|
              row(n)
            end
            others.each do |o|
              row(o)
            end
            if fruit.replaces
              row(:replaces)
            end
            row(:created_at)
            row(:issue)
          end
        end
        
        if fruit.respond_to?(:external_link) && !fruit.external_link.blank?
          h4 "External links"
          ArbreHelpers::HtmlHelper.show_links(self, fruit.external_link.split(',').compact)
        end
        if fruit.respond_to?(:extra_info)  && !fruit.extra_info.nil?
          h4 "Extra info"
          begin 
            if fruit.extra_info
              extra_info_as_json = JSON.parse(fruit.extra_info)
              ArbreHelpers::HtmlHelper.extra_info_renderer(self, extra_info_as_json)
            end
          rescue JSON::ParserError
            span fruit.extra_info
          end
        end
        fruit.attachments.each do |a|
          ArbreHelpers::Attachment.preview(self, a)
        end
      end
    end

    def self.current_fruits_panel(context, fruits_relation)
      context.instance_eval do
        fruits = resource.person.send(fruits_relation) || resource.person.send(fruits_relation.singularize)
        all = fruits.try(:count) ? fruits : [fruits].compact
        h3 "Current Fruits"
        if all.any?
          ArbreHelpers::Layout.panel_only(self, all) do |f|
            ArbreHelpers::Fruit.fruit_show_section(self, f)
          end          
        else
          ArbreHelpers::Layout.alert(self, "No items available", "info")
        end
      end
    end
  end
end
