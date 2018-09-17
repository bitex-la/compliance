class EventLog < ApplicationRecord
  belongs_to :admin_user, optional: true
  belongs_to :entity, polymorphic: true, optional: true
  ransackable_static_belongs_to :verb, class_name: 'EventLogKind'  
end
