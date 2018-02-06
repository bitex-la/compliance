class Issue < ApplicationRecord
  belongs_to :person, optional: true

  has_many :domicile_seeds
  has_many :identification_seeds
  has_many :funding_seeds
  has_many :natural_docket_seeds
  has_many :legal_entity_docket_seeds
  has_many :relationship_seeds

  has_many :comments, as: :commentable

  def get_seeds
    domicile_seeds + 
    identification_seeds +
    natural_docket_seeds +
    legal_entity_docket_seeds +
    funding_seeds +
    relationship_seeds
  end
end
