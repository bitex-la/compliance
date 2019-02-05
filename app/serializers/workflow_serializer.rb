class WorkflowSerializer 
  include FastJsonapiCandy::Serializer
  set_type 'workflows'
 
  build_timestamps
  build_belongs_to :issue
  build_has_many :tasks

  attributes :state
end