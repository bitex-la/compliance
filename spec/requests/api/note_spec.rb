require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe Note do
  it_behaves_like 'jsonapi show and index',
    :notes,
    :full_note_with_person,
    :alt_full_note_with_person,
    {title_cont: 'oh'},
    'title,person',
    'person,seed'

  it_behaves_like 'jsonapi show and index',
    :note_seeds,
    :full_note_seed_with_issue,
    :alt_full_note_seed_with_issue,
    {title_cont: 'oh'},
    'title,issue',
    'issue,attachments'

  it_behaves_like 'seed',
    :notes,
    :full_note,
    :alt_full_note

  it_behaves_like 'has_many fruit', :notes, :full_note
end
