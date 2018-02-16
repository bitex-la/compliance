require 'rails_helper'
require 'helpers/api/people_helper'

RSpec.describe Api::PeopleController, type: :controller do
  describe 'creating a person' do
    let(:basic_person) { Api::PeopleHelper.basic_person }

    it 'responds with an Unprocessable Entity HTTP code (422) when body is empty' do
      post :create,  params: {}
      assert_response 422
    end

    it 'creates a person' do
      post :create, params: basic_person
      expect(Person.count).to be_equal 1
      assert_response 201
    end
  end

  describe 'getting a person' do
    it 'shows all the person info when the person exist' do
      person = Person.create
      get :show, params: {id: person.id}
      assert_response 200
    end

    it 'responds with a not found error 404 when the person does not exist' do
      get :show, params: {id: 1}
      assert_response 404
    end
  end
end
