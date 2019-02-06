class TaskTypeSerializer
  include FastJsonapiCandy::Serializer
  set_type 'task_types'

  attributes *%i(name description)
end