require 'rails_helper'
require 'helpers/api/issues_helper'
require 'json'

describe Issue do
  let(:basic_issue) { Api::IssuesHelper.basic_issue }
  let(:invalid_basic_issue)  { Api::IssuesHelper.invalid_basic_issue }
  let(:issue_without_person) { Api::IssuesHelper.issue_without_person }

  describe 'creating an Issue' do
    it 'responds with an Unprocessable Entity HTTP code (422) when body is empty' do
      post :create,  params: {}
      assert_response 422
    end

    it 'creates a new person, then populates the issue' do
      post :create, params: basic_issue
      expect(Issue.count).to be_equal 1
      expect(Person.count).to be_equal 1
      assert_response 201
    end

    it 'creates a new issue associated to an existent person' do
      person = Person.create
      issue  = Api::IssuesHelper.issue_with_current_person(person.id)
      post :create, params: issue
      expect(Issue.count).to be_equal 1
      expect(Person.count).to be_equal 1
      expect(Issue.first.person.id).to be_equal person.id
      assert_response 201
    end

    describe 'creates a new issue with a domicile seed' do
      it 'including a png file attachment' do
        attachment = Base64.encode64(file_fixture('simple.png').read)
        issue  = Api::IssuesHelper.issue_with_domicile_seed(
          attachment, 
          'image/png',
          'file.png'
        )
        post :create, params: issue
        assert_issue_creation('DomicileSeed')
      end

      it 'including a jpg file attachment' do
        attachment = Base64.encode64(file_fixture('simple.jpg').read)
        issue  = Api::IssuesHelper.issue_with_domicile_seed(
          attachment,
          'image/jpg',
          'file.jpg'
        )
        post :create, params: issue
        assert_issue_creation('DomicileSeed')
      end

      it 'including a gif file attachment' do
        attachment = Base64.encode64(file_fixture('simple.gif').read)
        issue  = Api::IssuesHelper.issue_with_domicile_seed(
          attachment,
          'image/gif',
          'file.gif'
        )
        post :create, params: issue
        assert_issue_creation('DomicileSeed')
      end

      it 'including a pdf file attachment' do
        attachment = Base64.encode64(file_fixture('simple.pdf').read)
        issue  = Api::IssuesHelper.issue_with_domicile_seed(
          attachment,
          'application/pdf',
          'file.pdf'
        )
        post :create, params: issue
        assert_issue_creation('DomicileSeed')
      end

      it 'including a zip file attachment' do
        attachment = Base64.encode64(file_fixture('simple.zip').read)
        issue  = Api::IssuesHelper.issue_with_domicile_seed(
          attachment,
          'application/zip',
          'file.zip'
        )
        post :create, params: issue
        assert_issue_creation('DomicileSeed')
      end
    end

    describe 'creates a new issue with an identification seed' do
      it 'including a png file attachment' do
        attachment = Base64.encode64(file_fixture('simple.png').read)
        issue  = Api::IssuesHelper.issue_with_identification_seed(
          attachment, 
          'image/png',
          'file.png'
        )
        post :create, params: issue
        assert_issue_creation('IdentificationSeed')
      end

      it 'including a jpg file attachment' do
        attachment = Base64.encode64(file_fixture('simple.jpg').read)
        issue  = Api::IssuesHelper.issue_with_identification_seed(
          attachment,
          'image/jpg',
          'file.jpg'
        )
        post :create, params: issue
        assert_issue_creation('IdentificationSeed')
      end

      it 'including a gif file attachment' do
        attachment = Base64.encode64(file_fixture('simple.gif').read)
        issue  = Api::IssuesHelper.issue_with_identification_seed(
          attachment,
          'image/gif',
          'file.gif'
        )
        post :create, params: issue
        assert_issue_creation('IdentificationSeed')
      end

      it 'including a pdf file attachment' do
        attachment = Base64.encode64(file_fixture('simple.pdf').read)
        issue  = Api::IssuesHelper.issue_with_identification_seed(
          attachment,
          'application/pdf',
          'file.pdf'
        )
        post :create, params: issue
        assert_issue_creation('IdentificationSeed')
      end

      it 'including a zip file attachment' do
        attachment = Base64.encode64(file_fixture('simple.zip').read)
        issue  = Api::IssuesHelper.issue_with_identification_seed(
          attachment,
          'application/zip',
          'file.zip'
        )
        post :create, params: issue
        assert_issue_creation('IdentificationSeed')
      end
    end

    describe 'creates a new issue with a natural docket seed' do
      it 'including a png file attachment' do
        attachment = Base64.encode64(file_fixture('simple.png').read)
        issue  = Api::IssuesHelper.issue_with_natural_docket_seed(
          attachment, 
          'image/png',
          'file.png'
        )
        post :create, params: issue
        assert_issue_creation('NaturalDocketSeed')
      end

      it 'including a jpg file attachment' do
        attachment = Base64.encode64(file_fixture('simple.jpg').read)
        issue  = Api::IssuesHelper.issue_with_natural_docket_seed(
          attachment,
          'image/jpg',
          'file.jpg'
        )
        post :create, params: issue
        assert_issue_creation('NaturalDocketSeed')
      end

      it 'including a gif file attachment' do
        attachment = Base64.encode64(file_fixture('simple.gif').read)
        issue  = Api::IssuesHelper.issue_with_natural_docket_seed(
          attachment,
          'image/gif',
          'file.gif'
        )
        post :create, params: issue
        assert_issue_creation('NaturalDocketSeed')
      end

      it 'including a pdf file attachment' do
        attachment = Base64.encode64(file_fixture('simple.pdf').read)
        issue  = Api::IssuesHelper.issue_with_natural_docket_seed(
          attachment,
          'application/pdf',
          'file.pdf'
        )
        post :create, params: issue
        assert_issue_creation('NaturalDocketSeed')
      end

      it 'including a zip file attachment' do
        attachment = Base64.encode64(file_fixture('simple.zip').read)
        issue  = Api::IssuesHelper.issue_with_natural_docket_seed(
          attachment,
          'application/zip',
          'file.zip'
        )
        post :create, params: issue
        assert_issue_creation('NaturalDocketSeed')
      end
    end

    describe 'creates a new issue with a legal entity docket seed' do
      it 'including a png file attachment' do
        attachment = Base64.encode64(file_fixture('simple.png').read)
        issue  = Api::IssuesHelper.issue_with_legal_entity_docket_seed(
          attachment, 
          'image/png',
          'file.png'
        )
        post :create, params: issue
        assert_issue_creation('LegalEntityDocketSeed')
      end

      it 'including a jpg file attachment' do
        attachment = Base64.encode64(file_fixture('simple.jpg').read)
        issue  = Api::IssuesHelper.issue_with_legal_entity_docket_seed(
          attachment,
          'image/jpg',
          'file.jpg'
        )
        post :create, params: issue
        assert_issue_creation('LegalEntityDocketSeed')
      end

      it 'including a gif file attachment' do
        attachment = Base64.encode64(file_fixture('simple.gif').read)
        issue  = Api::IssuesHelper.issue_with_legal_entity_docket_seed(
          attachment,
          'image/gif',
          'file.gif'
        )
        post :create, params: issue
        assert_issue_creation('LegalEntityDocketSeed')
      end

      it 'including a pdf file attachment' do
        attachment = Base64.encode64(file_fixture('simple.pdf').read)
        issue  = Api::IssuesHelper.issue_with_legal_entity_docket_seed(
          attachment,
          'application/pdf',
          'file.pdf'
        )
        post :create, params: issue
        assert_issue_creation('LegalEntityDocketSeed')
      end

      it 'including a zip file attachment' do
        attachment = Base64.encode64(file_fixture('simple.zip').read)
        issue  = Api::IssuesHelper.issue_with_legal_entity_docket_seed(
          attachment,
          'application/zip',
          'file.zip'
        )
        post :create, params: issue
        assert_issue_creation('LegalEntityDocketSeed')
      end
    end

    describe 'creates a new issue with a quota seed' do
      it 'including a png file attachment' do
        attachment = Base64.encode64(file_fixture('simple.png').read)
        issue  = Api::IssuesHelper.issue_with_quota_seed(
          attachment, 
          'image/png',
          'file.png'
        )
        post :create, params: issue
        assert_issue_creation('QuotaSeed')
      end

      it 'including a jpg file attachment' do
        attachment = Base64.encode64(file_fixture('simple.jpg').read)
        issue  = Api::IssuesHelper.issue_with_quota_seed(
          attachment,
          'image/jpg',
          'file.jpg'
        )
        post :create, params: issue
        assert_issue_creation('QuotaSeed')
      end

      it 'including a gif file attachment' do
        attachment = Base64.encode64(file_fixture('simple.gif').read)
        issue  = Api::IssuesHelper.issue_with_quota_seed(
          attachment,
          'image/gif',
          'file.gif'
        )
        post :create, params: issue
        assert_issue_creation('QuotaSeed')
      end

      it 'including a pdf file attachment' do
        attachment = Base64.encode64(file_fixture('simple.pdf').read)
        issue  = Api::IssuesHelper.issue_with_quota_seed(
          attachment,
          'application/pdf',
          'file.pdf'
        )
        post :create, params: issue
        assert_issue_creation('QuotaSeed')
      end

      it 'including a zip file attachment' do
        attachment = Base64.encode64(file_fixture('simple.zip').read)
        issue  = Api::IssuesHelper.issue_with_quota_seed(
          attachment,
          'application/zip',
          'file.zip'
        )
        post :create, params: issue
        assert_issue_creation('QuotaSeed')
      end
    end

    it 'notifies that person id is invalid' do
      post :create, params: invalid_basic_issue
      expect(Issue.count).to be_equal 0
      expect(Person.count).to be_equal 0
      assert_response 404
    end

    it 'notifies that person is not associated' do
      post :create, params: issue_without_person
      expect(Issue.count).to be_equal 0
      expect(Person.count).to be_equal 0
      assert_response 422
    end
  end

  describe 'getting an issue' do
    it 'responds with a not found error 404 when the issue does not exist' do
      get :show, params: {id: 1}
      assert_response 404
    end

    it 'shows all the person info when the issue exist' do  
      attachment = Base64.encode64(file_fixture('simple.png').read)
      issue  = Api::IssuesHelper.issue_with_domicile_seed(
        attachment, 
        'image/png',
        'file.png'
      )
      post :create, params: issue
      get :show, params: {id: Issue.first.id}
      assert_response 200
    end
  end

  def assert_issue_creation(seed_type)
    expect(Issue.count).to be_equal 1
    expect(Person.count).to be_equal 1
    expect(seed_type.constantize.count).to be_equal 1
    expect(seed_type.constantize.where(issue: Issue.first).count).to be_equal 1
    expect(seed_type.constantize.first.attachments.count).to be_equal 1
    assert_response 201
  end

end
