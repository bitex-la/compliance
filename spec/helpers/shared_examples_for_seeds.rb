shared_examples 'archived_seed' do |seed_type|
  it 'can set archive_at to seed' do
    seed = create("#{seed_type}_archived_seed_with_issue")
    seed.issue.reload.approve!
    expect(seed.reload.fruit.archived_at).to eq seed.archived_at
  end
end

shared_examples "seed_scopeable" do |type, initial_factory, later_factory|
  seed_type = Garden::Naming.new(type).seed_plural
  initial_seed = "#{initial_factory}_seed"
  later_seed = "#{later_factory}_seed"

  describe "When filter by admin tags" do
    let(:admin_user) { AdminUser.current_admin_user = create(:admin_user) }

    before :each do
      admin_user
    end

    it "allow #{seed_type} creation only with person valid admin tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:alt_full_person_tagging).person

      issue1 = create(:basic_issue, person: person1)
      issue2 = create(:basic_issue, person: person2)

      admin_user.tags << person1.tags.first

      expect do
        seed1 = build(initial_seed, issue: Issue.find(issue1.id))
        seed1.save!
      end.to change { subject.class.count }.by(1)

      expect do
        subject.class.last.destroy
      end.to change { subject.class.count }.by(-1)

      expect { Issue.find(issue2.id) }.to raise_error(ActiveRecord::RecordNotFound)

      admin_user.tags << person2.tags.first

      expect do
        seed1 = build(initial_seed, issue: Issue.find(issue1.id))
        seed1.save!
      end.to change { subject.class.count }.by(1)

      expect do
        seed1 = build(initial_seed, issue: Issue.find(issue2.id))
        seed1.save!
      end.to change { subject.class.count }.by(1)
    end

    it "allow #{seed_type} creation with person tags if admin has no tags" do
      person = create(:full_person_tagging).person
      issue = create(:basic_issue, person: person)

      expect do
        seed = build(initial_seed, issue: Issue.find(issue.id))
        seed.save!
      end.to change { subject.class.count }.by(1)
    end

    it "allow #{seed_type} creation without person tags if admin has no tags" do
      person = create(:empty_person)
      issue = create(:basic_issue, person: person)

      expect do
        seed = build(initial_seed, issue: Issue.find(issue.id))
        seed.save!
      end.to change { subject.class.count }.by(1)
    end

    it "allow #{seed_type} creation without person tags if admin has tags" do
      person = create(:full_person_tagging).person
      issue = create(:basic_issue, person: person)

      admin_user.tags << person.tags.first

      expect do
        seed = build(initial_seed, issue: Issue.find(issue.id))
        seed.save!
      end.to change { subject.class.count }.by(1)
    end

    it "Update a #{seed_type} with person tags if admin has tags" do
      seed1, seed2, seed3, seed4 = setup_for_admin_tags_spec(initial_seed)
      person1 = seed1.issue.person
      person3 = seed3.issue.person

      admin_user.tags << person1.tags.first

      later_attrs = attributes_for(later_seed)

      seed = subject.class.find(seed1.id)
      seed.update!(later_attrs)

      seed = subject.class.find(seed2.id)
      seed.update!(later_attrs)

      expect { subject.class.find(seed3.id) }.to raise_error(ActiveRecord::RecordNotFound)

      seed = subject.class.find(seed4.id)
      seed.update!(later_attrs)

      admin_user.tags << person3.tags.first

      seed = subject.class.find(seed3.id)
      seed.update!(later_attrs)
    end

    it "Destroy a #{seed_type} with person tags if admin has tags" do
      seed1, seed2, seed3, seed4 = setup_for_admin_tags_spec(initial_seed)
      person1 = seed1.issue.person
      person3 = seed3.issue.person

      admin_user.tags << person1.tags.first

      expect(subject.class.find(seed1.id).destroy).to be_truthy
      expect(subject.class.find(seed2.id).destroy).to be_truthy
      expect { subject.class.find(seed3.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(subject.class.find(seed4.id).destroy).to be_truthy

      admin_user.tags << person3.tags.first

      expect(subject.class.find(seed3.id).destroy).to be_truthy
    end

    it "show #{seed_type} with admin user active tags" do
      seed1, seed2, seed3, seed4 = setup_for_admin_tags_spec(initial_seed)
      person1 = seed1.issue.person
      person3 = seed3.issue.person

      expect(subject.class.find(seed1.id)).to_not be_nil
      expect(subject.class.find(seed2.id)).to_not be_nil
      expect(subject.class.find(seed3.id)).to_not be_nil
      expect(subject.class.find(seed4.id)).to_not be_nil

      admin_user.tags << person1.tags.first

      expect(subject.class.find(seed1.id)).to_not be_nil
      expect(subject.class.find(seed2.id)).to_not be_nil
      expect { subject.class.find(seed3.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(subject.class.find(seed4.id)).to_not be_nil

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first

      expect { subject.class.find(seed1.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(subject.class.find(seed2.id)).to_not be_nil
      expect(subject.class.find(seed3.id)).to_not be_nil
      expect(subject.class.find(seed4.id)).to_not be_nil

      admin_user.tags << person1.tags.first

      expect(subject.class.find(seed1.id)).to_not be_nil
      expect(subject.class.find(seed2.id)).to_not be_nil
      expect(subject.class.find(seed3.id)).to_not be_nil
      expect(subject.class.find(seed4.id)).to_not be_nil
    end

    it "index #{seed_type} with admin user active tags" do
      seed1, seed2, seed3, seed4 = setup_for_admin_tags_spec(initial_seed)
      person1 = seed1.issue.person
      person3 = seed3.issue.person

      seeds = subject.class.all
      expect(seeds.count).to eq(4)
      expect(seeds[0].id).to eq(seed1.id)
      expect(seeds[1].id).to eq(seed2.id)
      expect(seeds[2].id).to eq(seed3.id)
      expect(seeds[3].id).to eq(seed4.id)

      admin_user.tags << person1.tags.first

      seeds = subject.class.all
      expect(seeds.count).to eq(3)
      expect(seeds[0].id).to eq(seed1.id)
      expect(seeds[1].id).to eq(seed2.id)
      expect(seeds[2].id).to eq(seed4.id)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first

      seeds = subject.class.all
      expect(seeds.count).to eq(3)
      expect(seeds[0].id).to eq(seed2.id)
      expect(seeds[1].id).to eq(seed3.id)
      expect(seeds[2].id).to eq(seed4.id)

      admin_user.tags << person1.tags.first

      seeds = subject.class.all
      expect(seeds.count).to eq(4)
      expect(seeds[0].id).to eq(seed1.id)
      expect(seeds[1].id).to eq(seed2.id)
      expect(seeds[2].id).to eq(seed3.id)
      expect(seeds[3].id).to eq(seed4.id)
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

      seed1.reload
      seed2.reload
      seed3.reload
      seed4.reload

      [seed1, seed2, seed3, seed4]
    end
  end
end
