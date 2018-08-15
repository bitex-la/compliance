class NaturalDocket < ApplicationRecord
  include Garden::Fruit
  include StaticModels::BelongsTo

  validates :nationality, country: true
  validates :gender, inclusion: { in: GenderKind.all }
  validates :marital_status, inclusion: { in: MaritalStatusKind.all }  
  
  belongs_to :marital_status, class_name: 'MaritalStatusKind'
  belongs_to :gender, class_name: 'GenderKind'
  
  def name
    build_name("#{first_name} #{last_name}")
  end
end
