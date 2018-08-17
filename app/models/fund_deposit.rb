class FundDeposit < ApplicationRecord
  include Loggable
  include StaticModels::BelongsTo

  validates :external_id, presence: true
  validates :deposit_method, inclusion: { in: DepositMethod.all }
  validates :currency, inclusion: { in: Currency.all }

  belongs_to :person
  belongs_to :deposit_method, class_name: "DepositMethod"
  belongs_to :currency, class_name: "Currency"

  has_many :attachments, as: :attached_to_fruit

  def name
    [self.class.name, id, amount, currency, deposit_method].join(',')
  end
end
