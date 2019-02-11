class TaskSerializer
  include FastJsonapiCandy::Serializer
  set_type 'tasks'

  attributes *%i(max_retries current_retries output state)
  build_timestamps

  build_belongs_to :workflow 
  build_belongs_to :task_type
end