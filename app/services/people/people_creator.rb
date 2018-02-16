class People::PeopleCreator
  def self.call(attributes)
    person = nil
    errors = []

    mapper = map_out(attributes)
    if mapper.all_valid?
      mapper.save_all
      person = Person.last
    else
      errors = mapper.all_errors
    end

    [person, errors]
  end

  private

  def self.map_out(attributes)
    JsonapiMapper.doc(
      attributes,
      person: [
        id: ''
      ]
    )
  end
end