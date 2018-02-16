class Issue < ApplicationRecord
  include AASM
  belongs_to :person

  has_one :domicile_seed
  has_many :identification_seeds
  has_many :natural_docket_seeds
  has_many :legal_entity_docket_seeds
  has_many :relationship_seeds
  has_many :quota_seeds

  has_many :comments, as: :commentable

  scope :recent, ->(page, per_page) { order(created_at: :desc).page(page).per(per_page) }

  aasm do
    state :new, :initial => true
  end

  def get_seeds
    domicile_seeds + 
    identification_seeds +
    natural_docket_seeds +
    legal_entity_docket_seeds +
    relationship_seeds +
    quota_seeds
  end
end
