require 'rails_helper'
require 'json'

describe ObservationReason do 
  let(:person) { create(:empty_person) }

  it_behaves_like 'jsonapi show and index',
    :observation_reasons,
    :observation_reason,
    :world_check_reason,
    {scope_eq: 'robot'},
    'scope,body_es',
    ''

  describe 'Creating a new ObservationReason' do
    it 'responds with (422) when body is empty' do
      api_create "/observation_reasons", {}, 422
    end

    it 'creates a new observation reason' do
      attributes = attributes_for(:world_check_reason)

      api_create "/observation_reasons", {
        type: 'observation_reasons',
        attributes: attributes
      }

      api_response.data.attributes.to_h.should >=
        attributes_for(:world_check_reason)
    end
  end
end

