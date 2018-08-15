class NaturalDocket < ApplicationRecord
  include Garden::Fruit
  include StaticModels::BelongsTo

  validates :nationality, country: true
  validates :gender, inclusion: { in: GenderKind.all.map(&:code) }
  validates :marital_status, inclusion: { in: MaritalStatusKind.all.map(&:code) }  

  belongs_to :gender, class_name: "GenderKind"
  belongs_to :marital_status, class_name: "MaritalStatusKind"
  
  def name
    build_name("#{first_name} #{last_name}")
  end
end
