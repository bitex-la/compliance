shared_examples 'archived_seed' do |seed_type|
  it 'can set archive_at to seed' do
    seed = create("#{seed_type}_archived_seed_with_issue")
    seed.issue.reload.approve!
    expect(seed.reload.fruit.archived_at).to eq seed.archived_at
  end
end
