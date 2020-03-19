require 'rails_helper'
require 'helpers/shared_examples_for_models'

RSpec.describe Observation, type: :model do
  %i(abandon dismiss reject).each do |event|
    it "scoped by admin return only observations who belongs to active issues, skip observations for issues in #{event} state" do
      issue = create(:basic_issue)
      another_issue = create(:basic_issue)
      worldcheck_observation = create(:admin_world_check_observation, issue: issue)
      risk_observation = create(:chainalysis_observation, issue: another_issue)
      
      Observation.admin_pending.count.should == 2
      another_issue.send("#{event}!")
      Observation.admin_pending.count.should == 1
      Observation.admin_pending.first.note.should == worldcheck_observation.note
    end
  end

  %i(note reply).each do |attr|
    it { is_expected.to strip_attribute attr }
  end

  it_behaves_like 'whitespaced_seed', described_class.new, {
    note: '  The note',
    reply: 'The reply  '
  }

  it 'create an observation with long accented text' do
    issue = create(:basic_issue)
    create(:strange_observation, issue: issue)
  end

  it 'preserve previous reply value if new value is nil' do
    obv = described_class.create(
      note: 'The note',
      reply: nil,
      issue: create(:basic_issue)
    )
  
    obv.update(reply: 'Reply from a backround process')
    expect(obv).to have_state(:answered)
    obv.update(reply: nil)
    expect(obv).to have_state(:answered)

    expect(obv.reload.reply).to eq 'Reply from a backround process'
    expect(obv).to have_state(:answered)
    assert_logging(obv, :update_entity, 2)

    obv.update(reply: 'Reply UPDATED from a backround process')

    expect(obv.reload.reply).to eq 'Reply UPDATED from a backround process'
    expect(obv).to have_state(:answered)
    assert_logging(obv, :update_entity, 3)
  end

  it "prevents save an observation if seed's issue do not match observation issue" do
    issue = create(:basic_issue)
    issue2 = create(:basic_issue)
    seed = issue.allowance_seeds.build
    seed.amount = 1000.50
    seed.kind_id = Currency.all.first.id
    obs = seed.observations.build
    obs.issue = issue2
    
    expect { issue.save! }.to raise_error(ActiveRecord::RecordInvalid,
      "Validation failed: Allowance seeds observations observable Issue and observable issue must match")
  end

  it "observation from another issue with same person appears in history scope" do
    create(:human_world_check_reason)
    issue = create(:basic_issue)
    seed = issue.allowance_seeds.build
    seed.amount = 1000.50
    seed.kind_id = Currency.all.first.id
    obs = seed.observations.build
    obs.observation_reason = ObservationReason.first
    obs.scope = :admin
    issue.save!

    issue2 = create(:basic_issue, person: issue.person)
    seed = issue2.allowance_seeds.build
    seed.amount = 1000.50
    seed.kind_id = Currency.all.first.id
    obs2 = seed.observations.build
    obs2.observation_reason = ObservationReason.first
    obs2.scope = :admin
    issue2.save!
    expect(Observation.history(issue)).to include obs2
  end

  it "observation from same issue do not appears in history scope" do
    create(:human_world_check_reason)
    issue = create(:basic_issue)
    seed = issue.allowance_seeds.build
    seed.amount = 1000.50
    seed.kind_id = Currency.all.first.id
    obs = seed.observations.build
    obs.observation_reason = ObservationReason.first
    obs.scope = :admin
    issue.save!

    expect(Observation.history(issue)).to_not include obs
  end

  it "observation from onother person do not appears in history scope" do
    create(:human_world_check_reason)
    issue = create(:basic_issue)
    seed = issue.allowance_seeds.build
    seed.amount = 1000.50
    seed.kind_id = Currency.all.first.id
    obs = seed.observations.build
    obs.observation_reason = ObservationReason.first
    obs.scope = :admin
    issue.save!

    issue2 = create(:basic_issue)
    seed = issue2.allowance_seeds.build
    seed.amount = 1000.50
    seed.kind_id = Currency.all.first.id
    obs2 = seed.observations.build
    obs2.observation_reason = ObservationReason.first
    obs2.scope = :admin
    issue2.save!
    expect(Observation.history(issue)).to_not include obs2
  end

  describe "When filter by admin tags" do
    let(:admin_user) { AdminUser.current_admin_user = create(:admin_user) }

    before :each do
      admin_user.tags.clear
      admin_user.save!
    end

    it "allow observation creation only with person valid admin tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:alt_full_person_tagging).person

      admin_user.tags << person1.tags.first
      admin_user.save!

      issue1 = create(:basic_issue, person: person1)
      issue2 = create(:basic_issue, person: person2)

      expect do
        obs = Observation.new(issue: Issue.find(issue1.id))
        obs.save!
      end.to change { Observation.count }.by(1)

      expect { Issue.find(issue2.id) }.to raise_error(ActiveRecord::RecordNotFound)

      admin_user.tags << person2.tags.first
      admin_user.save!

      expect do
        obs = Observation.new(issue: Issue.find(issue1.id))
        obs.save!
      end.to change { Observation.count }.by(1)

      expect do
        obs = Observation.new(issue: Issue.find(issue2.id))
        obs.save!
      end.to change { Observation.count }.by(1)
    end

    it "allow observation creation with person tags if admin has no tags" do
      person = create(:full_person_tagging).person
      issue = create(:basic_issue, person: person)

      expect do
        obs = Observation.new(issue: Issue.find(issue.id))
        obs.save!
      end.to change { Observation.count }.by(1)
    end

    it "allow observation creation without person tags if admin has no tags" do
      person = create(:empty_person)
      issue = create(:basic_issue, person: person)

      expect do
        obs = Observation.new(issue: Issue.find(issue.id))
        obs.save!
      end.to change { Observation.count }.by(1)
    end

    it "allow observation creation without person tags if admin has tags" do
      person = create(:full_person_tagging).person
      issue = create(:basic_issue, person: person)

      admin_user.tags << person.tags.first
      admin_user.save!

      expect do
        obs = Observation.new(issue: Issue.find(issue.id))
        obs.save!
      end.to change { Observation.count }.by(1)
    end

    it "Update an obsevation with person tags if admin has tags" do
      obs1, obs2, obs3, obs4 = setup_for_admin_tags_spec
      person1 = obs1.issue.person
      person3 = obs3.issue.person

      admin_user.tags << person1.tags.first
      admin_user.save!

      obs = Observation.find(obs1.id)
      obs.reply = "Some reply here"
      obs.save!

      obs = Observation.find(obs2.id)
      obs.reply = "Some reply here"
      obs.save!

      expect { Observation.find(obs3.id) }.to raise_error(ActiveRecord::RecordNotFound)

      obs = Observation.find(obs4.id)
      obs.reply = "Some reply here"
      obs.save!

      admin_user.tags << person3.tags.first
      admin_user.save!

      obs = Observation.find(obs3.id)
      obs.reply = "Some reply here"
      obs.save!
    end

    it "show observations with admin user active tags" do
      obs1, obs2, obs3, obs4 = setup_for_admin_tags_spec
      person1 = obs1.issue.person
      person3 = obs3.issue.person

      expect(Observation.find(obs1.id)).to_not be_nil
      expect(Observation.find(obs2.id)).to_not be_nil
      expect(Observation.find(obs3.id)).to_not be_nil
      expect(Observation.find(obs4.id)).to_not be_nil

      admin_user.tags << person1.tags.first
      admin_user.save!

      expect(Observation.find(obs1.id)).to_not be_nil
      expect(Observation.find(obs2.id)).to_not be_nil
      expect { Observation.find(obs3.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(Observation.find(obs4.id)).to_not be_nil

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      expect { Observation.find(obs1.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(Observation.find(obs2.id)).to_not be_nil
      expect(Observation.find(obs3.id)).to_not be_nil
      expect(Observation.find(obs4.id)).to_not be_nil

      admin_user.tags << person1.tags.first
      admin_user.save!

      expect(Observation.find(obs1.id)).to_not be_nil
      expect(Observation.find(obs2.id)).to_not be_nil
      expect(Observation.find(obs3.id)).to_not be_nil
      expect(Observation.find(obs4.id)).to_not be_nil
    end

    it "index observations with admin user active tags" do
      obs1, obs2, obs3, obs4 = setup_for_admin_tags_spec
      person1 = obs1.issue.person
      person3 = obs3.issue.person

      observations = Observation.all
      expect(observations.count).to eq(4)
      expect(observations[0].id).to eq(obs1.id)
      expect(observations[1].id).to eq(obs2.id)
      expect(observations[2].id).to eq(obs3.id)
      expect(observations[3].id).to eq(obs4.id)

      admin_user.tags << person1.tags.first
      admin_user.save!

      observations = Observation.all
      expect(observations.count).to eq(3)
      expect(observations[0].id).to eq(obs1.id)
      expect(observations[1].id).to eq(obs2.id)
      expect(observations[2].id).to eq(obs4.id)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      observations = Observation.all
      expect(observations.count).to eq(3)
      expect(observations[0].id).to eq(obs2.id)
      expect(observations[1].id).to eq(obs3.id)
      expect(observations[2].id).to eq(obs4.id)

      admin_user.tags << person1.tags.first
      admin_user.save!

      observations = Observation.all
      expect(observations.count).to eq(4)
      expect(observations[0].id).to eq(obs1.id)
      expect(observations[1].id).to eq(obs2.id)
      expect(observations[2].id).to eq(obs3.id)
      expect(observations[3].id).to eq(obs4.id)
    end

    def setup_for_admin_tags_spec
      person1 = create(:full_person_tagging).person
      person2 = create(:empty_person)
      person3 = create(:alt_full_person_tagging).person
      person4 = create(:empty_person)
      person4.tags << person1.tags.first
      person4.tags << person3.tags.first

      issue1 = create(:basic_issue, person: person1)
      issue2 = create(:basic_issue, person: person2)
      issue3 = create(:basic_issue, person: person3)
      issue4 = create(:basic_issue, person: person4)

      obs1 = create(:robot_observation, issue: issue1)
      obs2 = create(:robot_observation, issue: issue2)
      obs3 = create(:robot_observation, issue: issue3)
      obs4 = create(:robot_observation, issue: issue4)

      [obs1, obs2, obs3, obs4]
    end
  end
end
