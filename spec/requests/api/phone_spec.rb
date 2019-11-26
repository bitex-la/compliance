require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe Phone do
  it_behaves_like 'jsonapi show and index',
    :phones,
    :full_phone_with_person,
    :alt_full_phone_with_person,
    {has_whatsapp_eq: 'false'},
    'country,phone_kind_code,person',
    'person,seed'

  it_behaves_like 'jsonapi show and index',
    :phone_seeds,
    :full_phone_seed_with_issue,
    :alt_full_phone_seed_with_issue,
    {has_whatsapp_eq: 'false'},
    'country,phone_kind_code,issue',
    'issue,attachments'

  it_behaves_like 'max people allowed request limit',
    :phones,
    :full_phone_with_person

  it_behaves_like 'max people allowed request limit',
    :phone_seeds,
    :full_phone_seed_with_person

  it_behaves_like('seed', :phones, :full_phone, :alt_full_phone)

  it_behaves_like('has_many fruit', :phones, :full_phone)
end
