class FundTransfer < ApplicationRecord
  include Loggable

  validates :currency, inclusion: { in: Currency.all }
  validates :amount, :exchange_rate_adjusted_amount,
              numericality: { greater_than: 0 }
  validates :transfer_date, presence: true
  validates :external_id, presence: true

  belongs_to :source_person, class_name: 'Person'
  belongs_to :target_person, class_name: 'Person'
  ransackable_static_belongs_to :currency

  has_many :attachments, as: :attached_to_fruit

  include PersonScopeable

  def name
    "##{id}: #{source_person.name} -> #{target_person.name} (#{amount} #{currency_code})"
  end

  def self.collection_scoped_by_persons
    where(source_person_id: Person.by_admin_user_tags)
      .or(FundTransfer.where(target_person_id: Person.by_admin_user_tags))
  end

  def self.transfers_fiat_only_condition
    where(currency_id: Currency.all.select(&:is_fiat?)) if AdminUser.current_admin_user&.fiat_only?
  end
end
