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
