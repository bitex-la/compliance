module ArbreHelpers
  class Observation
    def self.has_many_observations(context, form, relation, read_only=false)
      ArbreHelpers::Form.has_many_form context, form, relation, cant_remove: true do |sfo, ctx|  
        if sfo.object.persisted? && read_only
          sfo.template.concat(
            Arbre::Context.new({}, sfo.template){
              ArbreHelpers::Observation.show_observation(self, sfo.object, true)
            }.to_s
          )
        else          
          observable = sfo.object.observable
          unless observable.nil?
            sfo.template.concat("<li>".html_safe) 
            sfo.template.concat("<label>Observable</label>".html_safe)
            sfo.template.concat context.link_to(observable.name, observable)
            sfo.template.concat('</li>'.html_safe)
          end

          sfo.input :observation_reason
          sfo.input :scope, as: :select
          sfo.input :note, input_html: {rows: 3}
          sfo.input :reply, input_html: {rows: 3}
        end
      end  
    end

    def self.show_observation(context, observation, read_only=false)
      context.instance_eval do
        if read_only
          attributes_table_for a do
            row(:observation){|o| link_to observation.name, observation }
          end
        else
          attributes_table_for observation, :observable, :observation_reason, :scope, :created_at, :updated_at
          para observation.note
          strong "Reply:"
          span observation.reply
        end
      end
    end

    def self.show_observations(context, observations, read_only=false)
      context.instance_eval do
        ArbreHelpers::Layout.panel_grid(self, observations) do |d|
          ArbreHelpers::Observation.show_observation(self, d, read_only)
        end  
      end
    end

    def self.show_seed_observations(context, observations)
      context.instance_eval do
        ArbreHelpers::Layout.alert(self, 
          "The seed has #{observations.count} observation#{ (observations.count > 1 ? 's' : '')}",
          "info") if observations.any?
      end
    end
  end
end