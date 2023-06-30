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
    return unless deposit_date.present? && deposit_date > DateTime.now.utc

    errors.add(:deposit_date, 'cannot be in the future')
  end

  belongs_to :person
  ransackable_static_belongs_to :deposit_method
  ransackable_static_belongs_to :currency

  has_many :attachments, as: :attached_to_fruit

  after_save :refresh_person_country_tagging!
  after_save :refresh_person_regularity!
  after_save { person.expire_action_cache }

  include PersonScopeable

  def name
    "##{id}: #{amount} #{currency_code} #{deposit_method_code}"
  end

  def self.deposits_fiat_only_condition
    where(currency_id: Currency.all.select(&:is_fiat?)) if AdminUser.current_admin_user&.fiat_only?
  end

  private

  def refresh_person_regularity!
    person.fund_deposits.reload
    person.refresh_person_regularity!
  end

  def refresh_person_country_tagging!
    person.refresh_person_country_tagging!(country)
  end
end
