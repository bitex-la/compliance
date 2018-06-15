class EventLog < ApplicationRecord
  belongs_to :admin_user, optional: true
  belongs_to :entity, polymorphic: true, optional: true

  enum verb: %i(
    create_entity 
    update_entity 
    delete_entity
    harvest_seed
  )
end
