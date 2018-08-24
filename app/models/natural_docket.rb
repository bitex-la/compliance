class NaturalDocket < ApplicationRecord
  include Garden::Fruit
  include StaticModels::BelongsTo
  
  belongs_to :marital_status, class_name: 'MaritalStatusKind', required: false
  belongs_to :gender, class_name: 'GenderKind', required: false
  
  def self.name_body(i)
    [i.first_name, i.last_name].join(' ')
  end
end
