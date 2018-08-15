class Allowance < ApplicationRecord
  include Garden::Fruit
  include StaticModels::BelongsTo

  belongs_to :kind, class_name: "Currency"

  def name
    [self.class.name, id, weight, amount, kind].join(',')    
  end
end
