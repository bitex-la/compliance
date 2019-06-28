module ArbreHelpers
  class Seed
    def self.seed_collection_show_tab(context, title, relation)
      Appsignal.instrument("render_#{relation.to_s}") do
        context.instance_eval do
          tab "#{title} (#{resource.send(relation).count})" do
            ArbreHelpers::Layout.panel_grid(self, resource.send(relation)) do |d|
              ArbreHelpers::Seed.seed_show_section(self, d)
            end
          end
        end
      end
    end

    def self.seed_show_section(context, seed, others = [])
      Appsignal.instrument("render_#{seed.class.name}") do
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
          attachments = seed.fruit ? seed.fruit.attachments : seed.attachments
          attachments.each do |a|
            ArbreHelpers::Attachment.preview(self, a)
          end
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
  end
end