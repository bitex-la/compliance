module ArbreHelpers
  class Layout
    def self.panel_grid(context, objects, &block)
      context.instance_eval do
        objects.in_groups_of(2).each do |group|
          columns do
            group.each_with_index do |a, i|
              column do
                next if a.nil?
                panel a.name do
                  instance_exec a, &block
                end
              end
            end
          end
        end
      end
    end

    def self.panel_only(context, objects, &block)
      context.instance_eval do
        objects.each do |o|
          panel o.name do
            instance_exec o, &block
          end
        end
      end
    end

    def self.tab_for(context, title, icon, extra="", &block)
      context.instance_eval do
        tab "#{fa_icon(icon, class: "fa-2x")} #{extra}".html_safe , { id: "#{title.gsub(" ", "-")}-tab", 
          html_options: { title: title } } do
          instance_exec &block
        end
      end
    end

    def self.tab_with_counter_for(context, title, relation, icon, &block)
      context.instance_eval do
        count = "<span class='badge-count'>#{resource.send(relation).count}</span>"
        ArbreHelpers::Layout.tab_for(self, title, icon, count) do
          instance_exec &block
        end
      end
    end

    def self.tab_with_text_for(context, title, icon, text, &block)
      context.instance_eval do
        text = "<span class='icon-text-fa'>#{text}</span>"
        ArbreHelpers::Layout.tab_for(self, title, icon, text) do
          instance_exec &block
        end
      end
    end
  end
end