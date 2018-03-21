class NaturalDocket < ApplicationRecord
  include Garden::Fruit
  validates :nationality, country: true
  validates :gender, gender: true
  validates :marital_status, marital_status: true  

  def name
    [id, first_name, last_name, gender].join(',')    
  end
end
