require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe EventLog do
  it_behaves_like 'jsonapi show and index',
    :event_logs,
    :issue_creation_event_log,
    :person_update_event_log,
    {verb_code_eq: 'update_entity'},
    'verb_code,entity_type',
    ''
end
