shared_examples 'person_scopable' do |options|
  creator = options[:create]
  let(:admin_user) { AdminUser.current_admin_user = create(:admin_user) }

  before :each do
    admin_user
  end

  it 'can only create for allowed persons' do
    # Admin Users can only create resources for persons
    # with whom they share at least one tag.
    allowed = create(:full_person_tagging).person
    forbidden = create(:alt_full_person_tagging).person

    admin_user.tags << allowed.tags.first
    admin_user.save!

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
    admin_user.save!

    expect { instance_exec(forbidden.id, &creator) }
      .to change { subject.class.count }.by(1)

    # Just to double check that creating for the allowed person still works.
    expect { instance_exec(allowed.id, &creator) }
      .to change { subject.class.count }.by(1)
  end

  it 'allow creation with person tags if admin has no tags' do
    allowed = create(:full_person_tagging).person

    expect { instance_exec(allowed.id, &creator) }
      .to change { subject.class.count }.by(1)
  end

  it "allow creation without person tags if admin has no tags" do
    allowed = create(:empty_person)

    expect { instance_exec(allowed.id, &creator) }
      .to change { subject.class.count }.by(1)
  end

  it "allow creation without person tags if admin has tags" do
    allowed = create(:full_person_tagging).person

    admin_user.tags << allowed.tags.first
    admin_user.save!

    expect { instance_exec(allowed.id, &creator) }
      .to change { subject.class.count }.by(1)
  end
end
