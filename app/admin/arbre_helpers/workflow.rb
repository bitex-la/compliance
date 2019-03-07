module ArbreHelpers
  class Workflow
    def self.render_workflow_progress(context, entity_type, object)
      color_suffix = object.completness_ratio < 99 ? 'orange' : ''
  
      context.instance_eval do
        if !object.performed?
          h3 class: 'light_header' do
            "#{object.workflow_type} #{entity_type} completed at #{object.completness_ratio}%"
          end
          div class: "meter #{color_suffix}" do
            span style: "width: #{object.completness_ratio}%"
          end
        else
          h3 class: 'light_header' do
            "#{object.workflow_type} #{entity_type} completed"
          end
        end
      end
    end
  end
end