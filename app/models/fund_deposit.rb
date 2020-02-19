class FundDeposit < ApplicationRecord
  include Loggable

  validates :country, country: true
  validates :deposit_date, presence: true
  validates :external_id, presence: true
  validates :deposit_method, inclusion: { in: DepositMethod.all }
  validates :currency, inclusion: { in: Currency.all }
  validates :amount, :exchange_rate_adjusted_amount,
    numericality: { greater_than: 0 }

  validate :deposit_date_cannot_be_in_the_future

  def deposit_date_cannot_be_in_the_future
    if deposit_date.present? && deposit_date > Date.today
      errors.add(:deposit_date, "cannot be in the future")
    end
  end

  belongs_to :person
  ransackable_static_belongs_to :deposit_method
  ransackable_static_belongs_to :currency

  has_many :attachments, as: :attached_to_fruit

  after_save :refresh_person_regularity!
  after_save{ person.expire_action_cache }

  def name
    "##{id}: #{amount} #{currency_code} #{deposit_method_code}"
  end

  private
  def refresh_person_regularity!
    person.fund_deposits.reload
    person.refresh_person_regularity!
  end

end
