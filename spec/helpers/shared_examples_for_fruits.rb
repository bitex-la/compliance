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

    fruit_class = seed1.fruit.class
    expect(fruit_class.current.include?(seed1.fruit)).to be_falsey
    expect(fruit_class.current.include?(seed2.fruit)).to be_truthy
    expect(fruit_class.archived(person).include?(seed1.fruit)).to be_truthy
    expect(fruit_class.archived(person).include?(seed2.fruit)).to be_falsey
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

    fruit_class = seed1.fruit.class
    expect(fruit_class.current.include?(seed1.fruit)).to be_falsey
    expect(fruit_class.current.include?(seed2.fruit)).to be_falsey
    expect(fruit_class.current.include?(seed3.fruit)).to be_falsey
    expect(fruit_class.archived(person).include?(seed1.fruit)).to be_truthy
    expect(fruit_class.archived(person).include?(seed2.fruit)).to be_falsey
    expect(fruit_class.archived(person).include?(seed3.fruit)).to be_truthy
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

    fruit_class = seed1.fruit.class
    expect(fruit_class.current.include?(seed1.fruit)).to be_falsey
    expect(fruit_class.current.include?(seed2.fruit)).to be_truthy
    expect(fruit_class.archived(person).include?(seed1.fruit)).to be_truthy
    expect(fruit_class.archived(person).include?(seed2.fruit)).to be_falsey
  end
end

shared_examples "fruit_scopeable" do |type, initial_factory|
  initial_seed = "#{initial_factory}_seed"

  describe "When filter by admin tags" do
    let(:admin_user) { AdminUser.current_admin_user = create(:admin_user) }

    before :each do
      admin_user
    end

    it "show #{type} with admin user active tags" do
      seed1, seed2, seed3, seed4 = setup_for_admin_tags_spec(initial_seed)
      person1 = seed1.issue.person
      person3 = seed3.issue.person

      expect(subject.class.find(seed1.fruit.id)).to_not be_nil
      expect(subject.class.find(seed2.fruit.id)).to_not be_nil
      expect(subject.class.find(seed3.fruit.id)).to_not be_nil
      expect(subject.class.find(seed4.fruit.id)).to_not be_nil

      admin_user.tags << person1.tags.first

      expect(subject.class.find(seed1.fruit.id)).to_not be_nil
      expect(subject.class.find(seed2.fruit.id)).to_not be_nil
      expect { subject.class.find(seed3.fruit.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(subject.class.find(seed4.fruit.id)).to_not be_nil

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first

      expect { subject.class.find(seed1.fruit.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(subject.class.find(seed2.fruit.id)).to_not be_nil
      expect(subject.class.find(seed3.fruit.id)).to_not be_nil
      expect(subject.class.find(seed4.fruit.id)).to_not be_nil

      admin_user.tags << person1.tags.first

      expect(subject.class.find(seed1.fruit.id)).to_not be_nil
      expect(subject.class.find(seed2.fruit.id)).to_not be_nil
      expect(subject.class.find(seed3.fruit.id)).to_not be_nil
      expect(subject.class.find(seed4.fruit.id)).to_not be_nil
    end

    it "index #{type} with admin user active tags" do
      seed1, seed2, seed3, seed4 = setup_for_admin_tags_spec(initial_seed)
      person1 = seed1.issue.person
      person3 = seed3.issue.person

      fruits = subject.class.all
      expect(fruits.count).to eq(4)
      expect(fruits[0].id).to eq(seed1.fruit.id)
      expect(fruits[1].id).to eq(seed2.fruit.id)
      expect(fruits[2].id).to eq(seed3.fruit.id)
      expect(fruits[3].id).to eq(seed4.fruit.id)

      admin_user.tags << person1.tags.first

      fruits = subject.class.all
      expect(fruits.count).to eq(3)
      expect(fruits[0].id).to eq(seed1.fruit.id)
      expect(fruits[1].id).to eq(seed2.fruit.id)
      expect(fruits[2].id).to eq(seed4.fruit.id)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first

      fruits = subject.class.all
      expect(fruits.count).to eq(3)
      expect(fruits[0].id).to eq(seed2.fruit.id)
      expect(fruits[1].id).to eq(seed3.fruit.id)
      expect(fruits[2].id).to eq(seed4.fruit.id)

      admin_user.tags << person1.tags.first

      fruits = subject.class.all
      expect(fruits.count).to eq(4)
      expect(fruits[0].id).to eq(seed1.fruit.id)
      expect(fruits[1].id).to eq(seed2.fruit.id)
      expect(fruits[2].id).to eq(seed3.fruit.id)
      expect(fruits[3].id).to eq(seed4.fruit.id)
    end
  end

  def setup_for_admin_tags_spec(initial_seed)
    person1 = create(:full_person_tagging).person
    person2 = create(:empty_person)
    person3 = create(:alt_full_person_tagging).person
    person4 = create(:empty_person)
    person4.tags << person1.tags.first
    person4.tags << person3.tags.first

    seed1 = create(initial_seed, issue: create(:basic_issue, person: person1))
    seed2 = create(initial_seed, issue: create(:basic_issue, person: person2))
    seed3 = create(initial_seed, issue: create(:basic_issue, person: person3))
    seed4 = create(initial_seed, issue: create(:basic_issue, person: person4))

    admin_user.tags.clear
    seed1.issue.reload.approve!
    admin_user.tags.clear
    seed2.issue.reload.approve!
    admin_user.tags.clear
    if seed2.issue.person.tags.count >= 1
      seed2.issue.person.tags.delete seed2.issue.person.tags.last
    end
    admin_user.tags.clear
    seed3.issue.reload.approve!
    admin_user.tags.clear
    seed4.issue.reload.approve!

    admin_user.tags.clear

    seed1.reload
    seed2.reload
    seed3.reload
    seed4.reload

    [seed1, seed2, seed3, seed4]
  end
end
