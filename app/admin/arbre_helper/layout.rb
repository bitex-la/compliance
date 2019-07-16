module ArbreHelpers
  class Layout
    def self.panel_grid(context, objects, &block)
      Appsignal.instrument("render_#{objects.klass.name}_grid") do
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
    end

    def self.panel_only(context, objects, &block)
      Appsignal.instrument("render_#{objects.klass.name}_grid") do
        context.instance_eval do
          objects.each do |o|
            panel o.name do
              instance_exec o, &block
            end
          end
        end
      end
    end
  end
end