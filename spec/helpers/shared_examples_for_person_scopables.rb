shared_examples 'person_scopable' do |options|
  creator = options[:create]
  let(:admin_user) { AdminUser.current_admin_user = create(:admin_user) }

  let(:allowed) do
    create(:full_person_tagging).person.tap do |p|
      admin_user.tags << p.tags.first
    end
  end

  before :each do
    admin_user
  end

  it 'can only create for allowed persons' do
    # Admin Users can only create resources for persons
    # with whom they share at least one tag.

    # Tagging the admin_user ensures access rules are applied to them.
    create(:admin_tagging_to_apply_rules, admin_user: admin_user)

    forbidden = create(:alt_full_person_tagging).person

    expect { Person.find(forbidden.id) }
      .to raise_error(ActiveRecord::RecordNotFound)

    expect { instance_exec(allowed.id, &creator) }
      .to change { subject.class.count }.by(1)

    # Using the exact same factory, for a forbidden id, is invalid.
    # The person should always be a required association for the resource,
    # and sending a forbidden ID should behave like sending an empty value.
    expect { instance_exec(forbidden.id, &creator) }
      .to raise_error(ActiveRecord::RecordInvalid)

    admin_user.tags << forbidden.tags.first

    expect { instance_exec(forbidden.id, &creator) }
      .to change { subject.class.count }.by(1)

    # Just to double check that creating for the allowed person still works.
    expect { instance_exec(allowed.id, &creator) }
      .to change { subject.class.count }.by(1)
  end

  it 'allow creation for a tagged person if admin has no tags' do
    allowed = create(:full_person_tagging).person

    expect { instance_exec(allowed.id, &creator) }
      .to change { subject.class.count }.by(1)
  end

  it "allow creation for an untagged person even when admin has tags" do
    create(:admin_tagging_to_apply_rules, admin_user: admin_user)
    allowed = create(:empty_person)

    expect { instance_exec(allowed.id, &creator) }
      .to change { subject.class.count }.by(1)
  end

  it "forbids updating resources with a forbidden person" do
    # We create an admin tagging to ensure tagged access rules still apply
    # even after we remove access for the 'allowed' user.
    forbidden = create(:alt_full_person_tagging).person
    resource = instance_exec(allowed.id, &creator)

    expect do
      options[:change_person].call(resource, forbidden.id)
      resource.save!
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "allows an untagged admin to update person to be anyone" do
    person = create(:full_person_tagging).person
    another = create(:alt_full_person_tagging).person
    resource = instance_exec(person.id, &creator)

    # Creating the resource and adding tags to it may tag the current
    # admin user, so we need to clear all tags here.
    admin_user.tags.clear

    expect do
      options[:change_person].call(resource, another.id)
      resource.save!
    end.not_to raise_error
  end

  it "allows a tagged admin to update person to be an untagged person" do
    create(:admin_tagging_to_apply_rules, admin_user: admin_user)
    resource = instance_exec(allowed.id, &creator)

    untagged = create(:empty_person)
    # This assertion is here to ensure this precondition is met even
    # if we implement auto-tagging features for new persons.
    expect(untagged.reload.tags).to be_empty

    expect do
      options[:change_person].call(resource, untagged.id)
      resource.save!
    end.not_to raise_error
  end

  it "allow fetching only if admin can manage the associated person by tags" do
    # We create an admin tagging to ensure tagged access rules still apply
    # even after we remove access for the 'allowed' user.
    create(:admin_tagging_to_apply_rules, admin_user: admin_user)

    resource = instance_exec(allowed.id, &creator)

    expect { subject.class.find(resource.id) }.not_to raise_error
    expect(subject.class.count).to eq 1

    allowed.tags.each { |t| admin_user.tags.delete t }

    expect { subject.class.find(resource.id) }
      .to raise_error(ActiveRecord::RecordNotFound)

    expect(subject.class.count).to eq 0

    admin_user.tags << allowed.tags.first

    expect { subject.class.find(resource.id) }.not_to raise_error
    expect(subject.class.count).to eq 1
  end

  it "allow fetching anything for an untagged person" do
    # We create an admin tagging to ensure tagged access rules still apply
    # even after we remove access for the 'allowed' user.
    create(:admin_tagging_to_apply_rules, admin_user: admin_user)
    untagged = create(:empty_person)

    resource = instance_exec(untagged.id, &creator)
    untagged.tags.clear # Just in case the creator added tags to this person.

    expect { subject.class.find(resource.id) }.not_to raise_error
    expect(subject.class.count).to eq 1

    create(:full_person_tagging, person: untagged)

    expect { subject.class.find(resource.id) }
      .to raise_error(ActiveRecord::RecordNotFound)
    expect(subject.class.count).to eq 0
  end

  it "allows untagged admin to access anything" do
    [:full_person_tagging, :alt_full_person_tagging].each do |f|
      person = create(f).person
      resource = instance_exec(person.id, &creator)

      # Creating the resource and adding tags to it may tag the current
      # admin user, so we need to clear all tags here.
      admin_user.tags.clear

      expect { subject.class.find(resource.id) }.not_to raise_error
    end

    expect(subject.class.count).to eq 2
  end
end
