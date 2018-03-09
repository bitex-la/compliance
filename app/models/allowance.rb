class Allowance < ApplicationRecord
  include Garden::Fruit

  def name
    [id, weight, amount, kind].join(',')    
  end
end
