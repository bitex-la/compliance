class Allowance < ApplicationRecord
  include Garden::Fruit
  include StaticModels::BelongsTo

  belongs_to :kind, class_name: "Currency"

  def self.name_body(i)
    "#{i.amount} #{i.kind}"
  end
end
