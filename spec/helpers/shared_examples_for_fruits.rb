shared_examples 'archived_fruit' do |fruit, seed_type|
  it 'can archive fruit' do
    seed1 = create("#{seed_type}_archived_seed_with_issue")
    issue = seed1.issue.reload
    seed2 = create("#{seed_type}_seed", issue: issue)
    issue.approve!
    person = issue.person.reload
    expect(person.send(fruit).include?(seed1.reload.fruit)).to be_falsey
    expect(person.send(fruit).include?(seed2.reload.fruit)).to be_truthy
    expect(person.send("#{fruit}_history").include?(seed1.fruit)).to be_truthy
  end

  it 'can create and replace a fruit with an archived one' do
    seed1 = create("#{seed_type}_archived_seed_with_issue")
    issue = seed1.issue.reload
    seed2 = create("#{seed_type}_seed", issue: issue)
    issue.approve!
    person = issue.person.reload
    expect(person.send(fruit).include?(seed1.reload.fruit)).to be_falsey
    expect(person.send(fruit).include?(seed2.reload.fruit)).to be_truthy
    expect(person.send("#{fruit}_history").include?(seed1.fruit)).to be_truthy

    issue = person.issues.create
    seed3 = create("#{seed_type}_archived_seed_with_issue", issue: issue, replaces: seed2.fruit)
    issue.reload.approve!
    person.reload
    expect(seed2.reload.fruit.replaced_by).to eq(seed3.reload.fruit)
    expect(person.send(fruit)).to be_empty
    expect(person.send("#{fruit}_history").include?(seed3.fruit)).to be_truthy
  end

  it 'can archive fruit with future date' do
    seed1 = create("#{seed_type}_future_archived_seed_with_issue")
    issue = seed1.issue.reload
    seed2 = create("#{seed_type}_seed", issue: issue)
    issue.approve!
    person = issue.person.reload

    expect(person.send(fruit).include?(seed1.reload.fruit)).to be_truthy
    expect(person.send(fruit).include?(seed2.reload.fruit)).to be_truthy
    expect(person.send("#{fruit}_history").include?(seed1.fruit)).to be_truthy

    Timecop.travel seed1.archived_at + 1
    person.reload
    expect(person.send(fruit).include?(seed1.reload.fruit)).to be_falsey
    expect(person.send(fruit).include?(seed2.reload.fruit)).to be_truthy
    expect(person.send("#{fruit}_history").include?(seed1.fruit)).to be_truthy
  end
end
