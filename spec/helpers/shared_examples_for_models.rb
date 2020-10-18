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

shared_examples 'model_validations' do |type|
  it 'has length validations' do
    errors = []
    type.columns
      .select { |c| c.type == :string }
      .map { |c| [c.name, c.limit] }
      .each do |c|
        validator = type.validators
          .select do |v|
            v.is_a?(ActiveRecord::Validations::LengthValidator) &&
              v.attributes.include?(c[0].to_sym)
          end.first

        if validator.nil?
          errors << "Not found LengthValidator for column #{c[0]} (#{c[1]})"
          next
        end

        if validator.options[:maximum] != c[1]
          errors << "LengthValidator mismatch for column #{c[0]} (#{c[1]},#{validator.options[:maximum]})"
        end
      end

    expect(errors).to be_empty, "#{errors}"
  end
end
