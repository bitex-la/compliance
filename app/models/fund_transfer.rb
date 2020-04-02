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

  def name
    "##{id}: #{source_person.name} -> #{target_person.name} (#{amount} #{currency_code})"
  end

  def self.default_scope
    unless (tags = AdminUser.current_admin_user&.active_tags)
      return nil
    end

    return nil if tags.empty?

    where(source_person_id: Person.all)
    # TODO
    #.or(FundTransfer.where(target_person_id: Person.all))
  end
end
