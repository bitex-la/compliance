require 'rails_helper'
require_relative '../../scripts/country_tags_cleaner'

describe CountryTagsCleaner do
  it 'Clean country tags' do
    person = create(:empty_person)
    person.refresh_person_country_tagging!('AR')
    person.refresh_person_country_tagging!('AN')
    other_tag = create(:person_tag)
    person.tags << other_tag

    expect(person.tags.count).to eq(3)
    expect(person.tags.first.name).to eq('active-in-AR')
    expect(person.tags.second.name).to eq('active-in-AN')
    expect(person.tags.last.name).to eq('this-is-a-person-tag-1')

    CountryTagsCleaner.perform!

    person.reload
    expect(person.tags.count).to eq(1)
    expect(person.tags.first.name).to eq('this-is-a-person-tag-1')
  end
end
