class TaskSerializer
  include FastJsonapiCandy::Serializer
  set_type 'tasks'

  build_timestamps

  build_belongs_to :workflow 
end