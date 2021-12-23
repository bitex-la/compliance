require 'rails_helper'

describe IssueToken do
  def api_create_issue_token(path, data, expected_status = 201)
    api_request_issue_token(:post, path, { data: data }, expected_status)
  end

  def api_update_issue_token(path, data, expected_status = 200)
    api_request_issue_token(:patch, path, { data: data }, expected_status)
  end

  def api_request_issue_token(method, path, params = {}, expected_status = 200)
    send(method, "/api#{path}", params: params)
    assert_response expected_status
  end

  let(:issue) { build(:basic_issue) }
  let(:seed) { build(:full_natural_docket_seed, issue: issue) }

  before(:each) do
    seed.observations << [build(:observation), build(:observation)]
    issue = seed.issue
    issue.save!
  end

  it 'show all observations from issue' do
    issue_token = IssueToken.where(issue: issue).first

    api_get("/issue_tokens/#{issue_token.token}/show_by_token")
    expect(api_response.included.count).to eq(2)
    expect(api_response.included.map(&:type).uniq).to eq(['observations'])
  end

  it 'responds with 410 error when token is invalid' do
    issue_token = IssueToken.where(issue: issue).first
    Timecop.travel 31.days.from_now

    api_get("/issue_tokens/#{issue_token.token}/show_by_token", {}, 410)
  end

  it 'does not return observations when they are answered' do
    issue_token = IssueToken.where(issue: issue).first
    observations = issue_token.observations

    observations.each do |observation|
      api_update_issue_token(
        "/issue_tokens/#{issue_token.token}/observations/#{observation.id}/reply",
        type: 'observations',
        id: observation.id,
        attributes: { reply: 'Some reply here' }
      )
    end
    expect(api_response.data.attributes.state).to eq('answered')

    api_get("/issue_tokens/#{issue_token.token}/show_by_token", {}, 410)
    expect(api_response.included).to be nil
  end

  it 'replies to an observation' do
    issue_token = IssueToken.where(issue: issue).first
    observations = issue_token.observations

    observations.each do |observation|
      api_update_issue_token(
        "/issue_tokens/#{issue_token.token}/observations/#{observation.id}/reply",
        type: 'observations',
        id: observation.id,
        attributes: { reply: 'Some reply here' }
      )
    end
    expect(api_response.data.attributes.state).to eq('answered')

    api_get "/issues/#{issue.id}"
    expect(api_response.data.attributes.state).to eq('answered')

    observations.each do |observation|
      api_get("/observations/#{observation.id}")
      expect(
        api_response.data.attributes.reply
      ).to eq('Some reply here')
    end
  end

  it 'returns an error if reply is empty' do
    issue_token = IssueToken.where(issue: issue).first
    observations = issue_token.observations

    observations.each do |observation|
      api_update_issue_token(
        "/issue_tokens/#{issue_token.token}/observations/#{observation.id}/reply",
        {
          type: 'observations',
          id: observation.id,
          attributes: { reply: '   ' }
        },
        422
      )
    end
  end

  it 'fails if replies to an already answered observation' do
    issue_token = IssueToken.where(issue: issue).first
    observations = issue_token.observations

    observations.each do |observation|
      api_update_issue_token(
        "/issue_tokens/#{issue_token.token}/observations/#{observation.id}/reply",
        type: 'observations',
        id: observation.id,
        attributes: { reply: 'Some reply here' }
      )
    end
    expect(api_response.data.attributes.state).to eq('answered')

    observations.each do |observation|
      api_update_issue_token(
        "/issue_tokens/#{issue_token.token}/observations/#{observation.id}/reply",
        {
          type: 'observations',
          id: observation.id,
          attributes: { reply: 'Some reply here' }
        },
        404
      )
    end
  end

  it 'replies to an observation with attachments' do
    issue_token = IssueToken.where(issue: issue).first
    observations = issue_token.observations

    observations.each do |observation|
      seed = observation.observable
      api_create_issue_token(
        "/issue_tokens/#{issue_token.token}/observations/#{observation.id}/attachments",
        type: 'attachments',
        relationships: { attached_to_seed: { data: { id: seed.id, type: 'natural_docket_seeds' } } },
        attributes: {
          document: "data:#{mime_for(:jpg)};base64,#{bytes_for('jpg')}",
          document_file_name: 'áñçfile微信图片.jpg',
          document_content_type: mime_for(:jpg)
        }
      )

      api_update_issue_token(
        "/issue_tokens/#{issue_token.token}/observations/#{observation.id}/reply",
        type: 'observations',
        id: observation.id,
        attributes: { reply: 'Some reply here' }
      )
      expect(api_response.data.attributes.state).to eq('answered')
    end

    api_get "/issues/#{issue.id}"
    expect(api_response.data.attributes.state).to eq('answered')

    observations.each do |observation|
      api_get("/observations/#{observation.id}")
      expect(
        api_response.data.attributes.reply
      ).to eq('Some reply here')
    end
  end

  it 'can not replies to an observation when token is invalid' do
    issue_token = IssueToken.where(issue: issue).first

    issue_token.observations.each do |observation|
      Timecop.travel 31.days.from_now
      api_update_issue_token(
        "/issue_tokens/#{issue_token.token}/observations/#{observation.id}/reply",
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
    api_update_issue_token(
      "/issue_tokens/#{issue_token.token}/observations/#{observation.id}/reply",
      {
        type: 'observations',
        id: observation.id,
        attributes: { reply: 'Some reply here' }
      },
      404
    )
  end

  it 'issue is only answered if all observations are replied' do
    issue_token = IssueToken.where(issue: issue).first
    observation = issue_token.observations.first

    api_update_issue_token(
      "/issue_tokens/#{issue_token.token}/observations/#{observation.id}/reply",
      type: 'observations',
      id: observation.id,
      attributes: { reply: 'Some reply here' }
    )
    expect(api_response.data.attributes.state).to eq('answered')

    api_get "/issues/#{issue.id}"
    expect(api_response.data.attributes.state).to eq('observed')
  end
end
