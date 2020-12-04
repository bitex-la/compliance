require 'rails_helper'
require_relative '../../scripts/allowances_updater'

describe AllowancesUpdater do
  it 'update allowances for AR persons' do
    tag = create(:person_tag, name: 'active-in-AR')

    p1, p2, p3 = 3.times do
      person = create(:empty_person)
      person.tags << tag
    end

    create(:savings_allowance_seed_with_person, person: p2, amount: 0)
    create(:savings_allowance_seed_with_person, person: p3, amount: 1000)

    AllowancesUpdater.perform!

    [p1, p2, p3].each do |p|
      expect(p.reload.allowances.count).to eq(1)
    end

    expect(person1.reload.allowances.first.amount).to eq(25_000)
    expect(person2.reload.allowances.first.amount).to eq(25_000)
    expect(person3.reload.allowances.first.amount).to eq(1000)
  end
end
