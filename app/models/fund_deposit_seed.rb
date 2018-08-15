class FundDepositSeed < ApplicationRecord
  include Garden::Seed
  include Garden::SelfHarvestable
  include StaticModels::BelongsTo

  validates :external_id, presence: true
  validates :deposit_method, inclusion: { in: DepositMethod.all }
  validates :currency, inclusion: { in: Currency.all }
  
  belongs_to :deposit_method, class_name: "DepositMethod"
  belongs_to :currency, class_name: "Currency"
end
