class NaturalDocket < ApplicationRecord
  include Garden::Fruit
  include Garden::Kindify
  validates :nationality, country: true
  #validates :gender, gender: true
  #validates :marital_status_id, marital_status: true  
  
  kind_mask_for :marital_status
  kind_mask_for :gender

  def name
    [id, first_name, last_name].join(',')    
  end
end
