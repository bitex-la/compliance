require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe RiskScore do
  it_behaves_like 'jsonapi show and index',
    :risk_scores,
    :full_risk_score_with_person,
    :alt_full_risk_score_with_person,
    {score_eq: 'red'},
    'score,provider,person',
    'person,seed'

  it_behaves_like 'jsonapi show and index',
    :risk_score_seeds,
    :full_risk_score_seed_with_issue,
    :alt_full_risk_score_seed_with_issue,
    {score_eq: 'red'},
    'score,provider,issue',
    'issue,attachments'

  it_behaves_like 'seed',
    :risk_scores,
    :full_risk_score,
    :alt_full_risk_score

  it_behaves_like 'has_many fruit',
    :risk_scores,
    :full_risk_score
end
