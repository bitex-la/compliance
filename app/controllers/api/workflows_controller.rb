class Api::WorkflowsController < Api::EntityController
  def resource_class
    Workflow
  end

  Workflow.aasm.events.map(&:name).each do |action|
    define_method(action) do
      workflow = Workflow.find(params[:id])
      begin
        workflow.aasm.fire!(action)
        jsonapi_response(workflow, {}, 200)
      rescue AASM::InvalidTransition => e
        jsonapi_error(422, "invalid transition")
      end
    end
  end

  protected
    def get_mapper 
      JsonapiMapper.doc_unsafe! params.permit!.to_h,
        [:issues, :workflows],
        issues: [],
        workflows: [
          :issue,
          :scope,
          :workflow_type
        ]
    end
end