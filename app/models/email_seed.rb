class EmailSeed < ApplicationRecord
  include Garden::Seed
  include SeedApiExpirable
  include StaticModels::BelongsTo

  validates :email_kind, inclusion: { in: EmailKind.all }

  belongs_to :email_kind, class_name: "EmailKind"
end
