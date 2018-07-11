PLURAL_SEEDS ||= %w(
  AffinitySeed
  PhoneSeed
  DomicileSeed
  EmailSeed
  IdentificationSeed
  AllowanceSeed
  RiskScoreSeed
  FundDepositSeed
  NoteSeed
)

SINGULAR_SEEDS ||= %w(
  NaturalDocketSeed
  LegalEntityDocketSeed
  ArgentinaInvoicingDetailSeed
  ChileInvoicingDetailSeed
)

SELF_HARVESTABLE_SEEDS ||= %w(
  FundDepositSeed
)

ALL_SEEDS ||= PLURAL_SEEDS + SINGULAR_SEEDS

def build_seed_payload(seed)
  if seed == 'AffinitySeed'
    related_person = create(:empty_person)
    related_person.save
    Api::SeedsHelper.affinity_seed(issue, related_person, :png)
  else
    Api::SeedsHelper.send(seed.underscore.to_sym, issue, :png)
  end
end

