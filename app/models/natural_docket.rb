class NaturalDocket < ApplicationRecord
  include Garden::Fruit
  include StaticModels::BelongsTo

  validates :nationality, country: true
  validates :gender, inclusion: { in: GenderKind.all }
  validates :marital_status, inclusion: { in: MaritalStatusKind.all }  
  
  belongs_to :marital_status, class_name: 'MaritalStatusKind'
  belongs_to :gender, class_name: 'GenderKind'
  
  def self.name_body(i)
    [i.first_name, i.last_name].join(' ')
  end
end
