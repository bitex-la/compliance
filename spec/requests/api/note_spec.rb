require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe Note do
  it_behaves_like 'jsonapi show and index',
    :notes,
    :full_note_with_person,
    :alt_full_note_with_person,
    {title_cont: 'oh'},
    'title,public,person',
    'person,seed'

  it_behaves_like 'jsonapi show and index',
    :note_seeds,
    :full_note_seed_with_issue,
    :alt_full_note_seed_with_issue,
    {title_cont: 'oh'},
    'title,public,issue',
    'issue,attachments'

  it_behaves_like 'max people allowed request limit',
    :notes,
    :full_note_with_person

  it_behaves_like 'max people allowed request limit',
    :note_seeds,
    :full_note_seed_with_person

  it_behaves_like 'seed',
    :notes,
    :full_note,
    :alt_full_note

  it_behaves_like 'has_many fruit', :notes, :full_note
end
