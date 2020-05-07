shared_examples 'whitespaced_seed' do |seed, attributes|
  it 'strips all whitespaces' do
    seed.update_attributes!(
      attributes.merge!(issue: create(:basic_issue))
    )

    attributes.each do |k, v|
      expect(seed.send(k)).to eq StripAttributes.strip(v)
    end
  end
end

shared_examples "seed_model" do |type, initial_factory, later_factory|
  seed_type = Garden::Naming.new(type).seed_plural
  initial_seed = "#{initial_factory}_seed"
  later_seed = "#{later_factory}_seed"
  seed_type_const = seed_type.to_s.camelize.singularize.constantize
  type_const = type.to_s.camelize.singularize.constantize

  describe "When filter by admin tags" do
    let(:admin_user) { AdminUser.current_admin_user = create(:admin_user) }

    before :each do
      admin_user
    end

    describe "seeds" do
      it "allow #{seed_type} creation only with person valid admin tags" do
        person1 = create(:full_person_tagging).person
        person2 = create(:alt_full_person_tagging).person

        issue1 = create(:basic_issue, person: person1)
        issue2 = create(:basic_issue, person: person2)

        admin_user.tags << person1.tags.first
        admin_user.save!

        expect do
          seed1 = build(initial_seed, issue: Issue.find(issue1.id))
          seed1.save!
        end.to change { seed_type_const.count }.by(1)

        expect do
          seed_type_const.last.destroy
        end.to change { seed_type_const.count }.by(-1)

        expect { Issue.find(issue2.id) }.to raise_error(ActiveRecord::RecordNotFound)

        admin_user.tags << person2.tags.first
        admin_user.save!

        expect do
          seed1 = build(initial_seed, issue: Issue.find(issue1.id))
          seed1.save!
        end.to change { seed_type_const.count }.by(1)

        expect do
          seed1 = build(initial_seed, issue: Issue.find(issue2.id))
          seed1.save!
        end.to change { seed_type_const.count }.by(1)
      end

      it "allow #{seed_type} creation with person tags if admin has no tags" do
        person = create(:full_person_tagging).person
        issue = create(:basic_issue, person: person)

        expect do
          seed = build(initial_seed, issue: Issue.find(issue.id))
          seed.save!
        end.to change { seed_type_const.count }.by(1)
      end

      it "allow #{seed_type} creation without person tags if admin has no tags" do
        person = create(:empty_person)
        issue = create(:basic_issue, person: person)

        expect do
          seed = build(initial_seed, issue: Issue.find(issue.id))
          seed.save!
        end.to change { seed_type_const.count }.by(1)
      end

      it "allow #{seed_type} creation without person tags if admin has tags" do
        person = create(:full_person_tagging).person
        issue = create(:basic_issue, person: person)

        admin_user.tags << person.tags.first
        admin_user.save!

        expect do
          seed = build(initial_seed, issue: Issue.find(issue.id))
          seed.save!
        end.to change { seed_type_const.count }.by(1)
      end

      it "Update a #{seed_type} with person tags if admin has tags" do
        seed1, seed2, seed3, seed4 = setup_for_admin_tags_spec(initial_seed)
        person1 = seed1.issue.person
        person3 = seed3.issue.person

        admin_user.tags << person1.tags.first
        admin_user.save!

        later_attrs = attributes_for(later_seed)

        seed = seed_type_const.find(seed1.id)
        seed.update!(later_attrs)

        seed = seed_type_const.find(seed2.id)
        seed.update!(later_attrs)

        expect { seed_type_const.find(seed3.id) }.to raise_error(ActiveRecord::RecordNotFound)

        seed = seed_type_const.find(seed4.id)
        seed.update!(later_attrs)

        admin_user.tags << person3.tags.first
        admin_user.save!

        seed = seed_type_const.find(seed3.id)
        seed.update!(later_attrs)
      end

      it "Destroy a #{seed_type} with person tags if admin has tags" do
        seed1, seed2, seed3, seed4 = setup_for_admin_tags_spec(initial_seed)
        person1 = seed1.issue.person
        person3 = seed3.issue.person

        admin_user.tags << person1.tags.first
        admin_user.save!

        expect(seed_type_const.find(seed1.id).destroy).to be_truthy
        expect(seed_type_const.find(seed2.id).destroy).to be_truthy
        expect { seed_type_const.find(seed3.id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect(seed_type_const.find(seed4.id).destroy).to be_truthy

        admin_user.tags << person3.tags.first
        admin_user.save!

        expect(seed_type_const.find(seed3.id).destroy).to be_truthy
      end

      it "show #{seed_type} with admin user active tags" do
        seed1, seed2, seed3, seed4 = setup_for_admin_tags_spec(initial_seed)
        person1 = seed1.issue.person
        person3 = seed3.issue.person

        expect(seed_type_const.find(seed1.id)).to_not be_nil
        expect(seed_type_const.find(seed2.id)).to_not be_nil
        expect(seed_type_const.find(seed3.id)).to_not be_nil
        expect(seed_type_const.find(seed4.id)).to_not be_nil

        admin_user.tags << person1.tags.first
        admin_user.save!

        expect(seed_type_const.find(seed1.id)).to_not be_nil
        expect(seed_type_const.find(seed2.id)).to_not be_nil
        expect { seed_type_const.find(seed3.id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect(seed_type_const.find(seed4.id)).to_not be_nil

        admin_user.tags.delete(person1.tags.first)
        admin_user.tags << person3.tags.first
        admin_user.save!

        expect { seed_type_const.find(seed1.id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect(seed_type_const.find(seed2.id)).to_not be_nil
        expect(seed_type_const.find(seed3.id)).to_not be_nil
        expect(seed_type_const.find(seed4.id)).to_not be_nil

        admin_user.tags << person1.tags.first
        admin_user.save!

        expect(seed_type_const.find(seed1.id)).to_not be_nil
        expect(seed_type_const.find(seed2.id)).to_not be_nil
        expect(seed_type_const.find(seed3.id)).to_not be_nil
        expect(seed_type_const.find(seed4.id)).to_not be_nil
      end

      it "index #{seed_type} with admin user active tags" do
        seed1, seed2, seed3, seed4 = setup_for_admin_tags_spec(initial_seed)
        person1 = seed1.issue.person
        person3 = seed3.issue.person

        seeds = seed_type_const.all
        expect(seeds.count).to eq(4)
        expect(seeds[0].id).to eq(seed1.id)
        expect(seeds[1].id).to eq(seed2.id)
        expect(seeds[2].id).to eq(seed3.id)
        expect(seeds[3].id).to eq(seed4.id)

        admin_user.tags << person1.tags.first
        admin_user.save!

        seeds = seed_type_const.all
        expect(seeds.count).to eq(3)
        expect(seeds[0].id).to eq(seed1.id)
        expect(seeds[1].id).to eq(seed2.id)
        expect(seeds[2].id).to eq(seed4.id)

        admin_user.tags.delete(person1.tags.first)
        admin_user.tags << person3.tags.first
        admin_user.save!

        seeds = seed_type_const.all
        expect(seeds.count).to eq(3)
        expect(seeds[0].id).to eq(seed2.id)
        expect(seeds[1].id).to eq(seed3.id)
        expect(seeds[2].id).to eq(seed4.id)

        admin_user.tags << person1.tags.first
        admin_user.save!

        seeds = seed_type_const.all
        expect(seeds.count).to eq(4)
        expect(seeds[0].id).to eq(seed1.id)
        expect(seeds[1].id).to eq(seed2.id)
        expect(seeds[2].id).to eq(seed3.id)
        expect(seeds[3].id).to eq(seed4.id)
      end
    end

    describe "fruits" do
      it "show #{type} with admin user active tags" do
        seed1, seed2, seed3, seed4 = setup_for_admin_tags_spec(initial_seed, true)
        person1 = seed1.issue.person
        person3 = seed3.issue.person

        expect(type_const.find(seed1.fruit.id)).to_not be_nil
        expect(type_const.find(seed2.fruit.id)).to_not be_nil
        expect(type_const.find(seed3.fruit.id)).to_not be_nil
        expect(type_const.find(seed4.fruit.id)).to_not be_nil

        admin_user.tags << person1.tags.first
        admin_user.save!

        expect(type_const.find(seed1.fruit.id)).to_not be_nil
        expect(type_const.find(seed2.fruit.id)).to_not be_nil
        expect { type_const.find(seed3.fruit.id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect(type_const.find(seed4.fruit.id)).to_not be_nil

        admin_user.tags.delete(person1.tags.first)
        admin_user.tags << person3.tags.first
        admin_user.save!

        expect { type_const.find(seed1.fruit.id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect(type_const.find(seed2.fruit.id)).to_not be_nil
        expect(type_const.find(seed3.fruit.id)).to_not be_nil
        expect(type_const.find(seed4.fruit.id)).to_not be_nil

        admin_user.tags << person1.tags.first
        admin_user.save!

        expect(type_const.find(seed1.fruit.id)).to_not be_nil
        expect(type_const.find(seed2.fruit.id)).to_not be_nil
        expect(type_const.find(seed3.fruit.id)).to_not be_nil
        expect(type_const.find(seed4.fruit.id)).to_not be_nil
      end

      it "index #{type} with admin user active tags" do
        seed1, seed2, seed3, seed4 = setup_for_admin_tags_spec(initial_seed, true)
        person1 = seed1.issue.person
        person3 = seed3.issue.person

        fruits = type_const.all
        expect(fruits.count).to eq(4)
        expect(fruits[0].id).to eq(seed1.fruit.id)
        expect(fruits[1].id).to eq(seed2.fruit.id)
        expect(fruits[2].id).to eq(seed3.fruit.id)
        expect(fruits[3].id).to eq(seed4.fruit.id)

        admin_user.tags << person1.tags.first
        admin_user.save!

        fruits = type_const.all
        expect(fruits.count).to eq(3)
        expect(fruits[0].id).to eq(seed1.fruit.id)
        expect(fruits[1].id).to eq(seed2.fruit.id)
        expect(fruits[2].id).to eq(seed4.fruit.id)

        admin_user.tags.delete(person1.tags.first)
        admin_user.tags << person3.tags.first
        admin_user.save!

        fruits = type_const.all
        expect(fruits.count).to eq(3)
        expect(fruits[0].id).to eq(seed2.fruit.id)
        expect(fruits[1].id).to eq(seed3.fruit.id)
        expect(fruits[2].id).to eq(seed4.fruit.id)

        admin_user.tags << person1.tags.first
        admin_user.save!

        fruits = type_const.all
        expect(fruits.count).to eq(4)
        expect(fruits[0].id).to eq(seed1.fruit.id)
        expect(fruits[1].id).to eq(seed2.fruit.id)
        expect(fruits[2].id).to eq(seed3.fruit.id)
        expect(fruits[3].id).to eq(seed4.fruit.id)
      end
    end

    def setup_for_admin_tags_spec(initial_seed, approve_issue = false)
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

      if approve_issue
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
      end

      admin_user.tags.clear

      seed1.reload
      seed2.reload
      seed3.reload
      seed4.reload

      [seed1, seed2, seed3, seed4]
    end
  end
end
