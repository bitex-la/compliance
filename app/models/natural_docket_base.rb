class NaturalDocketBase < ApplicationRecord
  self.abstract_class = true
  ransackable_static_belongs_to :marital_status, class_name: 'MaritalStatusKind',
    required: false
  ransackable_static_belongs_to :gender, class_name: 'GenderKind',
    required: false

  def name_body
    [first_name, last_name].join(' ')
  end
end
