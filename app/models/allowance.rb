class Allowance < ApplicationRecord
  include Garden::Fruit

  def name
    [self.class.name, id, weight, amount, kind].join(',')    
  end
end
