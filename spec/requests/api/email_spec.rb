require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe Email do
  it_behaves_like 'jsonapi show and index',
    :emails,
    :full_email_with_person,
    :alt_full_email_with_person,
    {email_kind_code_eq: 'personal'},
    'address,person',
    'person,seed'

  it_behaves_like 'jsonapi show and index',
    :email_seeds,
    :full_email_seed_with_issue,
    :alt_full_email_seed_with_issue,
    {email_kind_code_eq: 'personal'},
    'address,issue',
    'issue,attachments'

  it_behaves_like('seed', :emails, :full_email, :alt_full_email)

  it_behaves_like('has_many fruit', :emails, :full_email)
end
