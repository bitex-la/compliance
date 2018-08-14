class Allowance < ApplicationRecord
  include Garden::Fruit
  include Garden::Kindify

  kind_mask_for :kind, "Currency"

  def name
    [self.class.name, id, weight, amount, kind].join(',')    
  end
end
