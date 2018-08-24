class NaturalDocketSeed < ApplicationRecord
  include Garden::Seed
  include StaticModels::BelongsTo

  belongs_to :marital_status, class_name: 'MaritalStatusKind', required: false
  belongs_to :gender, class_name: 'GenderKind', required: false
end
