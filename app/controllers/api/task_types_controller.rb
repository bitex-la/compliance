class Api::TaskTypesController < Api::SeedController
  def resource_class
    TaskType
  end

  protected

  def get_mapper
    JsonapiMapper.doc_unsafe!(params.permit!.to_h,
      %w(task_types),
      { task_types: 
        %i(name description)}
  end
end