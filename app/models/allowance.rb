class Allowance < ApplicationRecord
  include Garden::Fruit
  include StaticModels::BelongsTo

  belongs_to :kind, class_name: "Currency"

  def name
    build_name("#{amount} #{kind}")
  end
end
