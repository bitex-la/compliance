module ArbreHelpers
  class Task
    def self.has_many_tasks(context, form)
      Appsignal.instrument("render_has_many_tasks") do
        ArbreHelpers::Form.has_many_form context, form, :tasks do |tf, ctx|
          task = tf.object
          tf.input :task_type, input_html: { disabled: task.persisted? } 
          tf.input :max_retries, input_html: { disabled: task.persisted? } 
          if !task.new_record?
            tf.input :state, input_html: { disabled: task.persisted? } 
          end
          if task.persisted?
            tf.input :current_retries, input_html: { disabled: true } 
            tf.input :output
            tf.input :_destroy, as: :boolean, required: false, label: 'Remove', class: "check_box_remove"
          end
        end
      end
    end
  end 
end