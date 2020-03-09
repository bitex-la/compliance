class FundDeposit < ApplicationRecord
  include Loggable

  validates :external_id, presence: true
  validates :deposit_method, inclusion: { in: DepositMethod.all }
  validates :currency, inclusion: { in: Currency.all }
  validates :amount, :exchange_rate_adjusted_amount,
    numericality: { greater_than: 0 }

  belongs_to :person
  ransackable_static_belongs_to :deposit_method
  ransackable_static_belongs_to :currency

  has_many :attachments, as: :attached_to_fruit

  after_save :refresh_person_regularity!
  after_save { person.expire_action_cache }

  def self.default_scope
    unless (tags = AdminUser.current_admin_user&.active_tags)
      return nil
    end

    return nil if tags.empty?

    where(person_id: Person.all)
  end

  def name
    "##{id}: #{amount} #{currency_code} #{deposit_method_code}"
  end

  private

  def refresh_person_regularity!
    person.fund_deposits.reload
    person.refresh_person_regularity!
  end
end
