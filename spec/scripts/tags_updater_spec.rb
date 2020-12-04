require 'rails_helper'
require_relative '../../scripts/tags_updater'

describe TagsUpdater do
  it 'update tags for countries' do
    Timecop.freeze 2000, 1, 1
    person = create(:empty_person)
    expect(person.tags).to be_empty
    create(:full_fund_deposit, country: 'PY', person: person)
    create(:full_fund_withdrawal, country: 'PY', person: person)
    person.tags.clear

    TagsUpdater.perform!

    person.reload
    expect(person.tags.count).to eq(1)
    expect(person.tags.map(&:name)).to eq(['active-in-AN'])
    person.tags.clear

    Timecop.freeze 2020, 5, 1
    create(:full_fund_deposit, country: 'CL', person: person)
    create(:full_fund_withdrawal, country: 'UY', person: person)
    person.tags.clear

    TagsUpdater.perform!

    person.reload
    expect(person.tags.count).to eq(3)
    expect(person.tags.map(&:name)).to eq(['active-in-AN', 'active-in-CL', 'active-in-UY'])
  end
end
