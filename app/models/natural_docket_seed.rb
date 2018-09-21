class NaturalDocketSeed < NaturalDocketBase
  include Garden::Seed

  validate do
    next unless issue
    next unless issue.natural_docket_seed
    current = NaturalDocketSeed.where(issue_id: issue.id).first
    next unless current && current != self
    errors.add(:base, "cannot_create_more_than_one_per_issue")
  end
end
