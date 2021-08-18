require 'rails_helper'

describe IssueToken do
  let(:issue) { build(:basic_issue) }
  let(:seed) { build(:full_natural_docket_seed, issue: issue) }

  before(:each) do
    seed.observations << [build(:observation), build(:robot_observation)]
    issue = seed.issue
    issue.save!
  end

  it 'show all observations from issue' do
    issue_token = IssueToken.where(issue: issue).first

    api_get("/issue_tokens/#{issue_token.token}")
    expect(api_response.included.first.relationships.observations.data.count).to eq(2)
  end

  it 'responds with 410 error when token is invalid' do
    issue_token = IssueToken.where(issue: issue).first
    Timecop.travel 31.days.from_now

    api_get("/issue_tokens/#{issue_token.token}", {}, 410)
  end

  it 'replies to an observation' do
    issue_token = IssueToken.where(issue: issue).first

    issue_token.observations.each do |observation|
      api_update(
        "/issue_tokens/#{issue_token.token}/observations/#{observation.id}",
        type: 'observations',
        id: observation.id,
        attributes: { reply: 'Some reply here' }
      )
    end
    expect(api_response.data.attributes.state).to eq('answered')

    api_get "/issues/#{issue.id}"
    expect(api_response.data.attributes.state).to eq('answered')

    api_get("/issue_tokens/#{issue_token.token}")
    expect(
      api_response.included
        .select { |datum| datum.type == 'observations' }
        .map(&:attributes).map(&:reply).uniq
    ).to eq(['Some reply here'])
  end

  it 'can not replies to an observation when token is invalid' do
    issue_token = IssueToken.where(issue: issue).first

    issue_token.observations.each do |observation|
      Timecop.travel 31.days.from_now
      api_update(
        "/issue_tokens/#{issue_token.token}/observations/#{observation.id}",
        {
          type: 'observations',
          id: observation.id,
          attributes: { reply: 'Some reply here' }
        },
        410
      )
    end
  end

  it 'can not replies to an observation not belonging to the issue token' do
    issue_token = IssueToken.where(issue: issue).first
    observation = create(:observation, issue: create(:basic_issue))
    api_update(
      "/issue_tokens/#{issue_token.token}/observations/#{observation.id}",
      {
        type: 'observations',
        id: observation.id,
        attributes: { reply: 'Some reply here' }
      },
      404
    )
  end
end
