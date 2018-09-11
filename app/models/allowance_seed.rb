class AllowanceSeed < ApplicationRecord
  include Garden::Seed
  include SeedApiExpirable
  include StaticModels::BelongsTo

  belongs_to :kind, class_name: "Currency"
end
