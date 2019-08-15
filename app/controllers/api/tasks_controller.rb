class Api::TasksController < Api::SeedController
  def resource_class
    Task
  end

  Task.aasm.events.map(&:name).each do |action|
    define_method(action) do
      task = Task.find(params[:id])
      begin
        task.aasm.fire!(action)
        jsonapi_response(task, {}, 200)
      rescue AASM::InvalidTransition => e
				jsonapi_error(422, "invalid transition")
      end
    end
  end

  protected
    def get_mapper
      JsonapiMapper.doc_unsafe! params.permit!.to_h,
        [:tasks, :workflows],
        workflows: [],
        tasks: [
          :output,
          :max_retries,
          :current_retries,
          :task_type,
          :workflow
        ]
    end 
end