class TaskSerializer
  include FastJsonapiCandy::Serializer
  set_type 'tasks'

  attributes *%i(max_retries current_retries output state task_type)
  build_timestamps

  build_belongs_to :workflow 
end