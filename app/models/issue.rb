class Issue < ApplicationRecord
  include AASM
  belongs_to :person, optional: true
  validates :person, presence: true

  HAS_ONE = %i{
    domicile_seed
    natural_docket_seed
    legal_entity_docket_seed
    identification_seed
  }.each do |relationship|  
    has_one relationship, required: false
    accepts_nested_attributes_for relationship, allow_destroy: true
  end

  HAS_MANY = %i{
    relationship_seeds
    allowance_seeds
  }.each do |relationship|
    has_many relationship
    accepts_nested_attributes_for relationship, allow_destroy: true
  end

  has_many :observations
  accepts_nested_attributes_for :observations, allow_destroy: true

  scope :recent, ->(page, per_page) { order(created_at: :desc).page(page).per(per_page) }

  aasm do
    state :new, :initial => true
  end

  def get_seeds
    seeds = [] 
    seeds << identification_seed if identification_seed.present?
    seeds << natural_docket_seed if natural_docket_seed.present?
    seeds << legal_entity_docket_seed if legal_entity_docket_seed.present?
    seeds += relationship_seeds 
    seeds += allowance_seeds  
    seeds << domicile_seed if domicile_seed.present?
    seeds
  end
end
