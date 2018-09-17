class NaturalDocketBase < ApplicationRecord
  self.abstract_class = true
  ransackable_static_belongs_to :marital_status, class_name: 'MaritalStatusKind',
    required: false
  ransackable_static_belongs_to :gender, class_name: 'GenderKind',
    required: false
end
