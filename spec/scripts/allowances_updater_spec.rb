require 'rails_helper'
require_relative '../../scripts/allowances_updater'

describe AllowancesUpdater do
  it 'update allowances for AR persons' do
    tag = create(:person_tag, name: 'active-in-AR')
    tag_cl = create(:person_tag, name: 'active-in-CL')

    p1, p2, p3, p4 = Array.new(4) do
      person = create(:empty_person)
      person.tags << tag
      person
    end

    person_cl = create(:empty_person)
    person_cl.tags << tag_cl

    create_allowance(p2, 0)
    create_allowance(p3, 1000)
    create_allowance(p4, nil)

    AllowancesUpdater.perform!

    [p1, p2, p3, p4].each do |p|
      expect(p.reload.allowances.count).to eq(1)
    end

    expect(p1.reload.allowances.first.amount).to eq(25_000)
    expect(p2.reload.allowances.first.amount).to eq(25_000)
    expect(p3.reload.allowances.first.amount).to eq(1000)
    expect(p4.reload.allowances.first.amount).to eq(25_000)

    expect(person_cl.reload.allowances.count).to eq(0)
  end

  def create_allowance(person, amount)
    issue = create(:basic_issue, person: person)
    create(:savings_allowance_seed_with_issue,
      issue: issue, amount: amount)
    issue.save!
    issue.approve!
  end
end
